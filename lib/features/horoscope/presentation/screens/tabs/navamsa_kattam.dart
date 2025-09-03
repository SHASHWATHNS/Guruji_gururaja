import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart' as svg;
import '../../../domain/entities/birth_input.dart'; // Import BirthInput class

class NavamsaKattamTab extends StatefulWidget {
  final BirthInput input;
  const NavamsaKattamTab({super.key, required this.input});

  @override
  State<NavamsaKattamTab> createState() => _NavamsaKattamTabState();
}

class _NavamsaKattamTabState extends State<NavamsaKattamTab> {
  static const _apiUrl = 'https://json.freeastrologyapi.com/navamsa-chart-svg-code'; // <-- New API URL
  static const _apiKey = 'Gn8Fe7i5YiOy87nmWxU19aycrUNs3Ug42u1dVC8f'; // <-- use your key
  String? _rawSvg;     // raw from API
  String? _svg;        // sanitized
  String? _error;      // error text to show
  bool _loading = true;
  bool _showXml = false; // toggle to display sanitized XML for inspection

  @override
  void initState() {
    super.initState();
    _fetchSvg();  // Fetch the SVG on initialization
  }

  Future<void> _fetchSvg() async {
    setState(() {
      _loading = true;
      _error = null;
      _rawSvg = null;
      _svg = null;
    });

    try {
      final input = widget.input;

      // Null checks for BirthInput fields
      if (input.dobLocal == null || input.tob24h == null || input.lat == null || input.lng == null) {
        setState(() {
          _error = 'Missing birth details or time of birth data.';
        });
        return;
      }

      final payload = {
        "year": input.dobLocal!.year,
        "month": input.dobLocal!.month,
        "date": input.dobLocal!.day,
        "hours": int.parse(input.tob24h!.split(":")[0]),
        "minutes": int.parse(input.tob24h!.split(":")[1]),
        "seconds": 0,
        "latitude": input.lat!,
        "longitude": input.lng!,
        "timezone": input.tzid == "Asia/Kolkata" ? 5.5 : 0,
        "config": {
          "observation_point": "topocentric",
          "ayanamsha": "lahiri",
        }
      };

      final res = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 20));

      debugPrint('📥 Response status: ${res.statusCode}');
      debugPrint('📥 Response body: ${res.body.substring(0, res.body.length.clamp(0, 400))}');

      if (res.statusCode < 200 || res.statusCode >= 300) {
        setState(() => _error = 'HTTP ${res.statusCode}: ${res.body}');
        return;
      }

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final rawSvg = decoded['output'] as String?;

      if (rawSvg == null || rawSvg.trim().isEmpty) {
        setState(() => _error = 'No "output" field (SVG) in API response.');
        return;
      }

      final cleaned = sanitizeSvg(rawSvg);

      try {
        final testWidget = svg.SvgPicture.string(
          cleaned,
          allowDrawingOutsideViewBox: true,
        );
        debugPrint('✅ SvgPicture.string parsed OK');
        setState(() {
          _rawSvg = rawSvg;
          _svg = cleaned;
        });
      } catch (e, st) {
        debugPrint('❌ Parser error: $e');
        debugPrint('❌ Stack: $st');
        setState(() {
          _rawSvg = rawSvg;
          _svg = cleaned;
          _error = 'Parser error: $e';
        });
        return;
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Debug helper
  String sanitizeSvg(String raw) {
    String out = raw;
    out = out.replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true, caseSensitive: false), '');
    out = out.replaceAll(RegExp(r'<defs>\s*</defs>', dotAll: true, caseSensitive: false), '');
    out = out.replaceAll(RegExp(r'stroke-linecap\s*=\s*"undefined"', caseSensitive: false), 'stroke-linecap="butt"');
    out = out.replaceAll(RegExp(r'stroke-linejoin\s*=\s*"undefined"', caseSensitive: false), 'stroke-linejoin="miter"');
    out = out.replaceAll(RegExp(r'\s+\w+(?:-\w+)*\s*=\s*"null"', caseSensitive: false), '');
    out = out.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navamsa Kattam'),  // <-- Updated title
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: _loading ? null : _fetchSvg,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: _showXml ? 'Hide XML' : 'Show XML',
            onPressed: () => setState(() => _showXml = !_showXml),
            icon: Icon(_showXml ? Icons.code_off : Icons.code),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Builder(
                builder: (_) {
                  if (_loading) return const CircularProgressIndicator();

                  if (_error != null) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: theme.colorScheme.error),
                          const SizedBox(height: 8),
                          Text(_error!, style: TextStyle(color: theme.colorScheme.error), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          if (_svg != null && _showXml)
                            SelectableText(
                              _svg!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          const SizedBox(height: 16),
                          FilledButton(onPressed: _fetchSvg, child: const Text('Try again')),
                        ],
                      ),
                    );
                  }

                  if (_svg == null) return const Text('No SVG data received.');

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Visible background to ensure you see the drawing area clearly
                      Container(
                        width: 400,
                        height: 400,
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: ClipRect(
                          child: InteractiveViewer(
                            boundaryMargin: const EdgeInsets.all(32),
                            minScale: 0.5,
                            maxScale: 8,
                            child: svg.SvgPicture.string(
                              _svg!,
                              key: ValueKey(_svg!.hashCode), // force repaint if string changes
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_showXml)
                        SizedBox(
                          height: 160,
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _svg!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
