import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';

/// Simple async submit mock you can replace with a repository later.
final _submitProvider = FutureProvider.family<void, _FeedbackPayload>((ref, payload) async {
  await Future.delayed(const Duration(milliseconds: 900));
  // TODO: send to API / Firebase / email, etc.
});

class ClassFeedbackScreen extends ConsumerStatefulWidget {
  const ClassFeedbackScreen({super.key});

  @override
  ConsumerState<ClassFeedbackScreen> createState() => _ClassFeedbackScreenState();
}

class _ClassFeedbackScreenState extends ConsumerState<ClassFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();

  // Fields
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _course = ValueNotifier<String?>(null);
  int _rating = 0;
  bool _recommend = true;
  final _good = TextEditingController();
  final _improve = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _course.dispose();
    _good.dispose();
    _improve.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = context.l10n.t;

    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('fb.error.rating'))),
      );
      return;
    }
    if (_course.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('fb.error.course'))),
      );
      return;
    }

    setState(() => _submitting = true);

    final payload = _FeedbackPayload(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      course: _course.value!,
      rating: _rating,
      recommend: _recommend,
      good: _good.text.trim(),
      improve: _improve.text.trim(),
    );

    try {
      await ref.read(_submitProvider(payload).future);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('fb.success'))),
      );
      Navigator.of(context).pop(); // or push to a "thank you" screen
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('fb.fail'))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n.t;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.headerBar,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t('app.title'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                t('fb.chip'), // "CLASS FEEDBACK"
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // Student info
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(t('fb.section.student')),
                    const SizedBox(height: 6),
                    _FieldText(
                      controller: _name,
                      label: t('fb.name'),
                      keyboardType: TextInputType.name,
                      validator: (v) => (v == null || v.trim().isEmpty) ? t('fb.required') : null,
                    ),
                    const SizedBox(height: 10),
                    _FieldText(
                      controller: _phone,
                      label: t('fb.phone'),
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (s.isEmpty) return t('fb.required');
                        if (s.length < 8) return t('fb.phone.invalid');
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    _FieldDropdown<String>(
                      label: t('fb.course'),
                      valueListenable: _course,
                      items: _courseOptions(t)
                          .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Experience
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(t('fb.section.experience')),
                    const SizedBox(height: 6),
                    Text(t('fb.rating'), style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _StarRating(
                      value: _rating,
                      onChanged: (v) => setState(() => _rating = v),
                    ),
                    const SizedBox(height: 12),
                    _FieldMultiline(
                      controller: _good,
                      label: t('fb.good'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    _FieldMultiline(
                      controller: _improve,
                      label: t('fb.improve'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _recommend,
                      onChanged: (v) => setState(() => _recommend = v),
                      title: Text(t('fb.recommend')),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _submitting
                    ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label: Text(t('fb.submit')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: _submitting ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _courseOptions(String Function(String) t) => [
    t('fb.course.basic'),       // Basic Astrology
    t('fb.course.prashna'),     // Prashna
    t('fb.course.matching'),    // Matching
    t('fb.course.panchanga'),   // Panchanga
    t('fb.course.numerology'),  // Numerology
    t('fb.course.other'),       // Other
  ];
}

class _FeedbackPayload {
  final String name;
  final String phone;
  final String course;
  final int rating;
  final bool recommend;
  final String good;
  final String improve;

  _FeedbackPayload({
    required this.name,
    required this.phone,
    required this.course,
    required this.rating,
    required this.recommend,
    required this.good,
    required this.improve,
  });
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _FieldText extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FieldText({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final br = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: br, enabledBorder: br, focusedBorder: br,
      ),
      textInputAction: TextInputAction.next,
    );
  }
}

class _FieldMultiline extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const _FieldMultiline({
    required this.controller,
    required this.label,
    required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final br = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        border: br, enabledBorder: br, focusedBorder: br,
      ),
    );
  }
}

class _FieldDropdown<T> extends StatelessWidget {
  final String label;
  final ValueListenable<T?> valueListenable;
  final List<DropdownMenuItem<T>> items;

  const _FieldDropdown({
    required this.label,
    required this.valueListenable,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final br = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );
    return ValueListenableBuilder<T?>(
      valueListenable: valueListenable,
      builder: (_, value, __) => InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: br, enabledBorder: br, focusedBorder: br,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            value: value,
            hint: Text(label),
            items: items,
            onChanged: (v) => (valueListenable as ValueNotifier<T?>).value = v,
          ),
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int value; // 0..5
  final ValueChanged<int> onChanged;
  const _StarRating({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < value;
        return IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () => onChanged(i + 1),
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 28,
            color: Colors.amber.shade700,
          ),
        );
      }),
    );
  }
}
