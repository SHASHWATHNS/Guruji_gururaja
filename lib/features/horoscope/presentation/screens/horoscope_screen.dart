import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodels/horoscope_form_view_model.dart';

class HoroscopeScreen extends ConsumerStatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  ConsumerState<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends ConsumerState<HoroscopeScreen> {
  // --- Controllers kept in State (smooth typing) ---
  final _nameCtrl = TextEditingController();

  // DOB split fields
  final _ddCtrl = TextEditingController();
  final _mmCtrl = TextEditingController();
  final _yyyyCtrl = TextEditingController();

  // Time (single HH:MM field; seconds default to 0)
  final _timeHmCtrl = TextEditingController();

  // Place (Autocomplete uses its own controller; keep initial here)
  String _initialPlace = '';

  // Lat/Lon (deg/min + dir) – free typing, range validated
  final _latDegCtrl = TextEditingController();
  final _latMinCtrl = TextEditingController();
  final _lonDegCtrl = TextEditingController();
  final _lonMinCtrl = TextEditingController();
  String _latDir = 'N';
  String _lonDir = 'E';

  // Time zone: IST default; simplified list
  _TimeZoneOption _tz = _timeZones.firstWhere((z) => z.id == 'Asia/Kolkata');

  // Form
  final _formKey = GlobalKey<FormState>();
  String? _latError;
  String? _lonError;
  DateTime? _pickedDob;

  InputDecoration _deco(String label, {Widget? suffix}) => InputDecoration(
    labelText: label,
    border: const UnderlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(vertical: 4),
    suffixIcon: suffix,
    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(width: 2)),
  );

  @override
  void initState() {
    super.initState();
    final f = ref.read(horoscopeFormProvider).form;

    _nameCtrl.text = f.name;
    if (f.day != null) _ddCtrl.text = f.day.toString().padLeft(2, '0');
    if (f.month != null) _mmCtrl.text = f.month.toString().padLeft(2, '0');
    if (f.year != null) _yyyyCtrl.text = f.year.toString();

    // Build HH:MM from hour/minute if present
    if (f.hour != null && f.minute != null) {
      _timeHmCtrl.text =
      '${f.hour!.toString().padLeft(2, '0')}:${f.minute!.toString().padLeft(2, '0')}';
    }

    _initialPlace = f.place;

    if (f.lonDeg != null) _lonDegCtrl.text = f.lonDeg.toString();
    if (f.lonMin != null) _lonMinCtrl.text = f.lonMin.toString();
    _lonDir = f.lonDir;

    if (f.latDeg != null) _latDegCtrl.text = f.latDeg.toString();
    if (f.latMin != null) _latMinCtrl.text = f.latMin.toString();
    _latDir = f.latDir;

    // Try to map saved tzHour/tzMinute to list (keeps IST default otherwise)
    final guessed = _timeZoneIdFromOffset(f.tzHour, f.tzMinute);
    if (guessed != null) {
      final found = _timeZones.where((z) => z.id == guessed);
      if (found.isNotEmpty) _tz = found.first;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ddCtrl.dispose();
    _mmCtrl.dispose();
    _yyyyCtrl.dispose();
    _timeHmCtrl.dispose();
    _latDegCtrl.dispose();
    _latMinCtrl.dispose();
    _lonDegCtrl.dispose();
    _lonMinCtrl.dispose();
    super.dispose();
  }

  DateTime? _tryBuildDate() {
    final dd = int.tryParse(_ddCtrl.text);
    final mm = int.tryParse(_mmCtrl.text);
    final yy = int.tryParse(_yyyyCtrl.text);
    if (dd == null || mm == null || yy == null) return null;
    try {
      final d = DateTime(yy, mm, dd);
      if (d.day != dd || d.month != mm || d.year != yy) return null;
      if (d.isAfter(DateTime.now())) return null;
      return d;
    } catch (_) {
      return null;
    }
  }

  // Parse HH:MM into hour/minute (seconds default 0)
  (int? h, int? m)? _parseHm() {
    final t = _timeHmCtrl.text.trim();
    final parts = t.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 24) return null;
    if (m < 0 || m > 59) return null;
    if (h == 24 && m != 0) return null;
    return (h, m);
  }

  // ---- NEW: robust decimal/deg-min parsing for lat/lon ----
  // Accepts:
  //  • Decimal degrees in deg field (min may be empty). Example: "-12.9716"
  //  • Deg+Min (integers) with direction dropdown.
  // Rules:
  //  • If deg is negative, we ignore dropdown and use the sign from the value.
  //  • If deg is decimal and min is empty, we convert to deg/min internally.
  //  • No "Invalid" shown while user is still typing deg with empty min (unless range exceeded).
  double? _degMinToDecimal(String degTxt, String minTxt, String dir, {required bool isLat}) {
    if (degTxt.trim().isEmpty) return null;

    final degDouble = double.tryParse(degTxt);
    if (degDouble == null) return null;

    final isNeg = degDouble.isNegative;
    final magDeg = degDouble.abs();

    double val;
    if (minTxt.trim().isEmpty) {
      // Decimal degrees path
      val = magDeg;
    } else {
      // Deg + Minutes path (ignore decimal fraction in degree to avoid double counting)
      final min = int.tryParse(minTxt);
      if (min == null || min < 0 || min >= 60) return null;
      final degInt = magDeg.floor();
      val = degInt + (min / 60.0);
    }

    // Range check on magnitude
    final limit = isLat ? 90.0 : 180.0;
    if (val < 0 || val > limit) return null;

    // Sign from negative value or from direction
    final signNegative = isNeg || ((isLat ? dir == 'S' : dir == 'W') && !isNeg);
    final signed = signNegative ? -val : val;
    return signed;
  }

  // Convert decimal degrees to deg/min + dir and push to VM + update controllers.
  void _applyDecimalToControllers({
    required bool isLat,
    required double dec,
  }) {
    var signNeg = dec.isNegative;
    var m = dec.abs();
    var degInt = m.floor();
    var minInt = ((m - degInt) * 60.0).round();
    if (minInt == 60) {
      degInt += 1;
      minInt = 0;
    }
    if (isLat) {
      _latDegCtrl.text = degInt.toString();
      _latMinCtrl.text = minInt.toString();
      _latDir = signNeg ? 'S' : 'N';
      ref.read(horoscopeFormProvider.notifier).setLatitude(
        deg: degInt,
        min: minInt,
        dir: _latDir,
      );
    } else {
      _lonDegCtrl.text = degInt.toString();
      _lonMinCtrl.text = minInt.toString();
      _lonDir = signNeg ? 'W' : 'E';
      ref.read(horoscopeFormProvider.notifier).setLongitude(
        deg: degInt,
        min: minInt,
        dir: _lonDir,
      );
    }
    setState(() {}); // refresh dropdown text
  }

  // Handle changes smoothly; do not mark invalid while incomplete.
  void _handleLatChanged() {
    final degTxt = _latDegCtrl.text;
    final minTxt = _latMinCtrl.text;

    if (degTxt.trim().isEmpty) {
      setState(() => _latError = null);
      return;
    }

    // Try decimal-only path first
    if (minTxt.trim().isEmpty && RegExp(r'\.').hasMatch(degTxt)) {
      final dd = double.tryParse(degTxt);
      if (dd == null) {
        setState(() => _latError = 'Invalid latitude');
        return;
      }
      final limit = 90.0;
      if (dd.abs() > limit) {
        setState(() => _latError = 'Latitude out of range');
        return;
      }
      // Convert and store as deg/min + dir
      _applyDecimalToControllers(isLat: true, dec: dd);
      setState(() => _latError = null);
      return;
    }

    // Deg+Min path (or integer deg with empty min → treat as incomplete, no error)
    final dec = _degMinToDecimal(degTxt, minTxt, _latDir, isLat: true);
    if (dec == null) {
      // If minutes empty but deg integer, don't scare the user with error yet.
      if (minTxt.trim().isEmpty && !degTxt.contains('.')) {
        setState(() => _latError = null);
      } else {
        setState(() => _latError = 'Invalid latitude');
      }
      return;
    }
    // Push to VM
    ref.read(horoscopeFormProvider.notifier).setLatitude(
      deg: int.tryParse(degTxt.replaceAll(RegExp(r'\..*$'), '')) ?? int.tryParse(degTxt),
      min: minTxt.isEmpty ? 0 : int.tryParse(minTxt),
      dir: _latDir,
    );
    setState(() => _latError = null);
  }

  void _handleLonChanged() {
    final degTxt = _lonDegCtrl.text;
    final minTxt = _lonMinCtrl.text;

    if (degTxt.trim().isEmpty) {
      setState(() => _lonError = null);
      return;
    }

    if (minTxt.trim().isEmpty && RegExp(r'\.').hasMatch(degTxt)) {
      final dd = double.tryParse(degTxt);
      if (dd == null) {
        setState(() => _lonError = 'Invalid longitude');
        return;
      }
      final limit = 180.0;
      if (dd.abs() > limit) {
        setState(() => _lonError = 'Longitude out of range');
        return;
      }
      _applyDecimalToControllers(isLat: false, dec: dd);
      setState(() => _lonError = null);
      return;
    }

    final dec = _degMinToDecimal(degTxt, minTxt, _lonDir, isLat: false);
    if (dec == null) {
      if (minTxt.trim().isEmpty && !degTxt.contains('.')) {
        setState(() => _lonError = null);
      } else {
        setState(() => _lonError = 'Invalid longitude');
      }
      return;
    }
    ref.read(horoscopeFormProvider.notifier).setLongitude(
      deg: int.tryParse(degTxt.replaceAll(RegExp(r'\..*$'), '')) ?? int.tryParse(degTxt),
      min: minTxt.isEmpty ? 0 : int.tryParse(minTxt),
      dir: _lonDir,
    );
    setState(() => _lonError = null);
  }

  String? _timeZoneIdFromOffset(int? hour, int? minute) {
    if (hour == null || minute == null) return null;
    for (final z in _timeZones) {
      if (z.hour == hour && z.minute == minute) return z.id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(horoscopeFormProvider);
    final notifier = ref.read(horoscopeFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.headerBar,
        title: const Text(
          'GURUJI GURURAJA',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Colors.black),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.history)),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              // Page bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration:
                BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                child: const Center(
                  child: Text('HOROSCOPE',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),

              // Name
              TextFormField(
                controller: _nameCtrl,
                decoration: _deco('Name'),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Name is required';
                  if (t.length < 2) return 'Enter a valid name';
                  return null;
                },
                onChanged: notifier.setName,
              ),
              const SizedBox(height: 10),

              // DOB
              Row(
                children: [
                  Expanded(
                    flex: 24,
                    child: TextFormField(
                      controller: _ddCtrl,
                      decoration: _deco('DD (01-31)'),
                      keyboardType:
                      const TextInputType.numberWithOptions(signed: false, decimal: false),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2)
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (_) {
                        final dd = int.tryParse(_ddCtrl.text);
                        if (dd == null || dd < 1 || dd > 31) return 'Invalid';
                        return null;
                      },
                      onChanged: (v) => notifier.setDOB(d: int.tryParse(v)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 24,
                    child: TextFormField(
                      controller: _mmCtrl,
                      decoration: _deco('MM (01-12)'),
                      keyboardType:
                      const TextInputType.numberWithOptions(signed: false, decimal: false),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2)
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (_) {
                        final mm = int.tryParse(_mmCtrl.text);
                        if (mm == null || mm < 1 || mm > 12) return 'Invalid';
                        return null;
                      },
                      onChanged: (v) => notifier.setDOB(m: int.tryParse(v)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 32,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextFormField(
                          controller: _yyyyCtrl,
                          decoration: _deco('YYYY'),
                          keyboardType:
                          const TextInputType.numberWithOptions(signed: false, decimal: false),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4)
                          ],
                          textInputAction: TextInputAction.next,
                          validator: (_) {
                            final yyyy = int.tryParse(_yyyyCtrl.text);
                            if (yyyy == null || yyyy < 1900 || yyyy > DateTime.now().year) {
                              return 'Invalid';
                            }
                            final d = _tryBuildDate();
                            if (d == null) return 'Invalid';
                            _pickedDob = d;
                            return null;
                          },
                          onChanged: (v) => notifier.setDOB(y: int.tryParse(v)),
                        ),
                        IconButton(
                          tooltip: 'Pick from calendar',
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () async {
                            final now = DateTime.now();
                            final initial =
                                _pickedDob ?? _tryBuildDate() ?? DateTime(now.year - 20, 1, 1);
                            final res = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1900),
                              lastDate: now,
                              initialDate: initial,
                            );
                            if (res != null) {
                              _pickedDob = res;
                              _ddCtrl.text = res.day.toString().padLeft(2, '0');
                              _mmCtrl.text = res.month.toString().padLeft(2, '0');
                              _yyyyCtrl.text = res.year.toString();
                              notifier.setDOB(d: res.day, m: res.month, y: res.year);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Time of Birth (HH:MM) — user types, IST timezone default
              TextFormField(
                controller: _timeHmCtrl,
                decoration: const InputDecoration(
                  labelText: 'Time of Birth (HH:MM)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}:?\d{0,2}$')),
                  _HmAutofillFormatter(), // inserts ':' after HH if you type 2 digits
                ],
                validator: (_) {
                  final hm = _parseHm();
                  if (hm == null) return 'Enter time like 05:30';
                  return null;
                },
                onChanged: (_) {
                  final hm = _parseHm();
                  if (hm != null) {
                    ref.read(horoscopeFormProvider.notifier).setTOB(
                      h: hm.$1,
                      min: hm.$2,
                      s: 0,
                    );
                  }
                },
              ),
              const SizedBox(height: 12),

              // Time Zone — simplified list, IST default and visible
              DropdownButtonFormField<_TimeZoneOption>(
                value: _tz,
                isExpanded: true,
                items: _timeZones
                    .map((z) => DropdownMenuItem<_TimeZoneOption>(value: z, child: Text(z.label)))
                    .toList(),
                onChanged: (z) {
                  if (z == null) return;
                  setState(() => _tz = z);
                  ref.read(horoscopeFormProvider.notifier).setTimeZone(_tz.hour, _tz.minute);
                },
                decoration: const InputDecoration(
                  labelText: 'Time Zone (default: IST)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),

              // Place of Birth (Autocomplete)
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue ve) {
                  final q = ve.text.trim().toLowerCase();
                  if (q.isEmpty) return const Iterable<String>.empty();
                  return _majorPlaces.where((p) => p.toLowerCase().contains(q)).take(100);
                },
                onSelected: (sel) => ref.read(horoscopeFormProvider.notifier).setPlace(sel),
                fieldViewBuilder: (context, fieldController, focusNode, onSubmit) {
                  if (_initialPlace.isNotEmpty && fieldController.text.isEmpty) {
                    fieldController.text = _initialPlace;
                    fieldController.selection = TextSelection.fromPosition(
                        TextPosition(offset: fieldController.text.length));
                    _initialPlace = '';
                  }
                  return TextFormField(
                    controller: fieldController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Place of Birth (type to search)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Place is required' : null,
                    onChanged: ref.read(horoscopeFormProvider.notifier).setPlace,
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  final maxW = MediaQuery.of(context).size.width - 32;
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 320, maxWidth: maxW),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (_, i) {
                              final opt = options.elementAt(i);
                              return ListTile(title: Text(opt), onTap: () => onSelected(opt));
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Longitude (accept decimal or deg+min)
              _DegMinRow(
                label: 'Longitude',
                degCtrl: _lonDegCtrl,
                minCtrl: _lonMinCtrl,
                dir: _lonDir,
                dirItems: const ['E', 'W'],
                onDir: (v) {
                  setState(() => _lonDir = v);
                  ref.read(horoscopeFormProvider.notifier).setLongitude(dir: v);
                  _handleLonChanged(); // re-validate on direction change
                },
                onChanged: _handleLonChanged,
              ),
              if (_lonError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(_lonError!, style: const TextStyle(color: AppColors.danger)),
                ),
              const SizedBox(height: 8),

              // Latitude (accept decimal or deg+min)
              _DegMinRow(
                label: 'Latitude',
                degCtrl: _latDegCtrl,
                minCtrl: _latMinCtrl,
                dir: _latDir,
                dirItems: const ['N', 'S'],
                onDir: (v) {
                  setState(() => _latDir = v);
                  ref.read(horoscopeFormProvider.notifier).setLatitude(dir: v);
                  _handleLatChanged(); // re-validate on direction change
                },
                onChanged: _handleLatChanged,
              ),
              if (_latError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(_latError!, style: const TextStyle(color: AppColors.danger)),
                ),
              const SizedBox(height: 8),

              const Text(
                'Note: DST is not implemented. So please provide DST corrected Time of Birth',
                style: TextStyle(color: AppColors.danger, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Checkbox(
                    value: vm.form.saveInPhone,
                    onChanged: (v) =>
                        ref.read(horoscopeFormProvider.notifier).toggleSave(v ?? true),
                  ),
                  const Text('Save birth details in phone'),
                ],
              ),
              const SizedBox(height: 8),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final initial =
                            _pickedDob ?? _tryBuildDate() ?? DateTime(now.year - 20, 1, 1);
                        final res = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          lastDate: now,
                          initialDate: initial,
                        );
                        if (res != null) {
                          _pickedDob = res;
                          _ddCtrl.text = res.day.toString().padLeft(2, '0');
                          _mmCtrl.text = res.month.toString().padLeft(2, '0');
                          _yyyyCtrl.text = res.year.toString();
                          ref
                              .read(horoscopeFormProvider.notifier)
                              .setDOB(d: res.day, m: res.month, y: res.year);
                        }
                      },
                      child: const Text('OPEN'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _formKey.currentState?.reset();
                        _nameCtrl.clear();
                        _ddCtrl.clear();
                        _mmCtrl.clear();
                        _yyyyCtrl.clear();
                        _timeHmCtrl.clear();
                        _latDegCtrl.clear();
                        _latMinCtrl.clear();
                        _lonDegCtrl.clear();
                        _lonMinCtrl.clear();
                        setState(() {
                          _latDir = 'N';
                          _lonDir = 'E';
                          _pickedDob = null;
                          _latError = null;
                          _lonError = null;
                          _tz = _timeZones.firstWhere((z) => z.id == 'Asia/Kolkata');
                          _initialPlace = '';
                        });
                        ref.read(horoscopeFormProvider.notifier).clear();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Form cleared')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text('CLEAR'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: vm.submitting
                          ? null
                          : () async {
                        final ok = _formKey.currentState?.validate() ?? false;

                        // Validate & push time (HH:MM)
                        final hm = _parseHm();
                        if (hm == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter time like 05:30')),
                          );
                          return;
                        } else {
                          ref.read(horoscopeFormProvider.notifier).setTOB(
                            h: hm.$1,
                            min: hm.$2,
                            s: 0,
                          );
                        }

                        // Validate lat/lon ranges (final check)
                        final decLat = _degMinToDecimal(
                            _latDegCtrl.text, _latMinCtrl.text, _latDir,
                            isLat: true);
                        final decLon = _degMinToDecimal(
                            _lonDegCtrl.text, _lonMinCtrl.text, _lonDir,
                            isLat: false);
                        setState(() {
                          _latError = (decLat == null) ? 'Invalid latitude' : null;
                          _lonError = (decLon == null) ? 'Invalid longitude' : null;
                        });

                        if (!ok || decLat == null || decLon == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fix validation errors')),
                          );
                          return;
                        }

                        await ref.read(horoscopeFormProvider.notifier).submit();
                        if (context.mounted &&
                            ref.read(horoscopeFormProvider).form.isValidBasic) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Submitted (mock)')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: vm.submitting
                          ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('SUBMIT'),
                    ),
                  ),
                ],
              ),
              if (vm.error != null) ...[
                const SizedBox(height: 12),
                Text(vm.error!, style: const TextStyle(color: AppColors.danger)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// --- Helpers & UI bits -----------------------------------------------------

class _DegMinRow extends StatelessWidget {
  final String label;
  final TextEditingController degCtrl;
  final TextEditingController minCtrl;
  final String dir;
  final List<String> dirItems;
  final VoidCallback? onChanged;
  final ValueChanged<String>? onDir;

  const _DegMinRow({
    required this.label,
    required this.degCtrl,
    required this.minCtrl,
    required this.dir,
    required this.dirItems,
    this.onChanged,
    this.onDir,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label:  '),
        SizedBox(
          width: 86, // allow more digits/decimals
          child: TextFormField(
            controller: degCtrl,
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            // Allow negatives and decimals in degree box
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$'))],
            decoration: const InputDecoration(
              isDense: true,
              hintText: '° or decimal',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => onChanged?.call(),
            validator: (_) => null,
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 78,
          child: TextFormField(
            controller: minCtrl,
            keyboardType: TextInputType.number,
            // Minutes remain integer 0..59; leave free then validate
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              isDense: true,
              hintText: "′ (0-59)",
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => onChanged?.call(),
            validator: (_) => null,
          ),
        ),
        const SizedBox(width: 6),
        DropdownButton<String>(
          value: dir,
          items: dirItems.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => onDir?.call(v ?? dir),
        ),
      ],
    );
  }
}

// Autofill ":" after HH (e.g., typing "053" -> "05:3")
class _HmAutofillFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (text.length == 2 && !text.contains(':')) {
      text = '$text:';
      return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
    }
    return newValue;
  }
}

// Expanded “S” coverage + popular global places (grow freely)
const List<String> _majorPlaces = [
  // India (incl. S cities)
  'Salem, India','Surat, India','Srinagar, India','Secunderabad, India','Shimla, India',
  'Silchar, India','Solapur, India','Siliguri, India','Satara, India','Sangli, India',
  'Chennai, India','Bengaluru, India','Hyderabad, India','Mumbai, India','Delhi, India','Kolkata, India',
  'Pune, India','Ahmedabad, India','Jaipur, India','Coimbatore, India','Madurai, India','Tiruchirappalli, India',
  // Asia
  'Singapore','Seoul, South Korea','Shanghai, China','Shenzhen, China','Siem Reap, Cambodia',
  'Sapporo, Japan','Sendai, Japan','Suzhou, China','Surabaya, Indonesia',
  'Bangkok, Thailand','Jakarta, Indonesia','Kuala Lumpur, Malaysia','Tokyo, Japan','Osaka, Japan','Manila, Philippines',
  // Europe (add S countries/places)
  'Stockholm, Sweden','Gothenburg, Sweden','Malmo, Sweden','Sodertalje, Sweden',
  'Stuttgart, Germany','Strasbourg, France','Seville, Spain','Santander, Spain','Salamanca, Spain',
  'Sofia, Bulgaria','Split, Croatia','Salzburg, Austria','St. Gallen, Switzerland',
  'London, United Kingdom','Paris, France','Rome, Italy','Milan, Italy','Berlin, Germany','Amsterdam, Netherlands',
  // Americas
  'San Francisco, USA','San Jose, USA','San Diego, USA','Seattle, USA','Sacramento, USA',
  'Santiago, Chile','Sao Paulo, Brazil','Santo Domingo, Dominican Republic','San Juan, Puerto Rico',
  'New York, USA','Los Angeles, USA','Chicago, USA','Houston, USA','Toronto, Canada','Vancouver, Canada',
  // Africa (S examples)
  'Suez, Egypt','Sokoto, Nigeria','Sfax, Tunisia','Sousse, Tunisia','Sharm El Sheikh, Egypt',
  'Cape Town, South Africa','Johannesburg, South Africa','Nairobi, Kenya','Accra, Ghana','Lagos, Nigeria',
  // Oceania
  'Sydney, Australia','Sunshine Coast, Australia','Surfers Paradise, Australia','Auckland, New Zealand',
  // Countries starting with S (so typing “S” still shows them)
  'Sweden','Sudan','Somalia','Spain','Switzerland','Serbia','Slovakia','Slovenia','Singapore (Country)','South Africa',
];

// Major time zones (short list), IST default/primary
class _TimeZoneOption {
  final String id;   // IANA id
  final String label;
  final int hour;
  final int minute;
  const _TimeZoneOption(this.id, this.label, this.hour, this.minute);
}

const List<_TimeZoneOption> _timeZones = [
  _TimeZoneOption('Asia/Kolkata', 'UTC+05:30 — Asia/Kolkata (IST)', 5, 30), // default
  _TimeZoneOption('UTC', 'UTC±00:00 — UTC', 0, 0),
  _TimeZoneOption('Europe/London', 'UTC+01:00 — Europe/London (DST)', 1, 0),
  _TimeZoneOption('Asia/Dubai', 'UTC+04:00 — Asia/Dubai', 4, 0),
  _TimeZoneOption('Asia/Singapore', 'UTC+08:00 — Asia/Singapore', 8, 0),
  _TimeZoneOption('Asia/Tokyo', 'UTC+09:00 — Asia/Tokyo', 9, 0),
  _TimeZoneOption('Australia/Sydney', 'UTC+10:00 — Australia/Sydney (DST)', 10, 0),
  _TimeZoneOption('America/New_York', 'UTC-04:00 — America/New_York (DST)', -4, 0),
  _TimeZoneOption('America/Los_Angeles', 'UTC-07:00 — America/Los_Angeles (DST)', -7, 0),
];
