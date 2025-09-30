// lib/features/horoscope/data/svg_tools.dart
import 'dart:convert';

/// Small cell representation for our 4x4 ring grid (with hollow 2x2 center)
class _RingCell {
  _RingCell(this.row, this.col, this.left, this.top, this.right, this.bottom);
  final int row, col;
  final double left, top, right, bottom;
  @override
  bool operator ==(Object o) => o is _RingCell && o.row == row && o.col == col;
  @override
  int get hashCode => Object.hash(row, col);
}

class SvgTools {
  /// Extract vendor canvas size from viewBox/width/height
  static ({double w, double h}) _vendorSizeFromSvg(String raw) {
    final viewBoxMatch = RegExp(r'viewBox="([\d\.\s\-]+)"').firstMatch(raw);
    double w = 500, h = 500;
    if (viewBoxMatch != null) {
      final parts = viewBoxMatch.group(1)!.trim().split(RegExp(r'\s+'));
      if (parts.length == 4) {
        w = double.tryParse(parts[2]) ?? 500;
        h = double.tryParse(parts[3]) ?? 500;
      }
    } else {
      final wM = RegExp(r'width="([\d\.]+)"').firstMatch(raw);
      final hM = RegExp(r'height="([\d\.]+)"').firstMatch(raw);
      w = double.tryParse(wM?.group(1) ?? '') ?? 500;
      h = double.tryParse(hM?.group(1) ?? '') ?? 500;
    }
    final size = w < h ? w : h;
    return (w: size, h: size);
  }

  /// Map vendor x,y into our ring cell; null for center
  static _RingCell? _mapToRingCell(double x, double y, double w, double h) {
    final tX = w / 4.0, tY = h / 4.0;
    final col = (x / tX).floor().clamp(0, 3);
    final row = (y / tY).floor().clamp(0, 3);
    final inCenter = (row == 1 || row == 2) && (col == 1 || col == 2);
    if (inCenter) return null;
    final left = col * tX, top = row * tY, right = left + tX, bottom = top + tY;
    return _RingCell(row, col, left, top, right, bottom);
  }

  /// Extract ring labels from a vendor SVG by scanning <text ...>...</text>
  static Map<_RingCell, List<String>> extractRingLabels(String raw) {
    final size = _vendorSizeFromSvg(raw);
    final w = size.w, h = size.h;
    final textRe = RegExp(r'<text([^>]*)>(.*?)</text>', dotAll: true);
    final xRe = RegExp(r'\bx="([\d\.\-]+)"');
    final yRe = RegExp(r'\by="([\d\.\-]+)"');

    bool looksMeta(String s) {
      final t = s.toLowerCase();
      return t.contains('am') || t.contains('pm') || t.contains('east')
          || RegExp(r'\d{1,2}[:.]\d{2}').hasMatch(t)
          || RegExp(r'\d+\s?[nsew]').hasMatch(t)
          || RegExp(r'(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)', caseSensitive: false).hasMatch(t)
          || t.contains('chart');
    }

    final labels = <_RingCell, List<String>>{};
    for (final m in textRe.allMatches(raw)) {
      final attrs = m.group(1) ?? '';
      var txt = (m.group(2) ?? '').trim();
      if (txt.isEmpty || looksMeta(txt)) continue;
      final mx = xRe.firstMatch(attrs);
      final my = yRe.firstMatch(attrs);
      if (mx == null || my == null) continue;

      final x = double.tryParse(mx.group(1)!) ?? 0;
      final y = double.tryParse(my.group(1)!) ?? 0;

      final cell = _mapToRingCell(x, y, w, h);
      if (cell == null) continue;

      // Normalize retro markers to (va)
      txt = txt.replaceAll(RegExp(r'(Rx|\(R\)|retro)', caseSensitive: false), '(va)');
      labels.putIfAbsent(cell, () => <String>[]).add(txt);
    }
    return labels;
  }

  /// Build a clean 12-house kattam SVG (no external <style>), with provided labels
  static String buildKattam12Svg({
    required double size,
    double stroke = 2,
    String strokeColor = '#000',
    String fillColor = '#fff',
    String? title,
    Map<_RingCell, List<String>> labels = const {},
  }) {
    final t = size / 4;
    final sb = StringBuffer()
      ..writeln('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $size $size" width="$size" height="$size">')
      ..writeln('<style>rect,line{shape-rendering:crispEdges;} text{font-family:-apple-system,Roboto,Inter,"Noto Sans Tamil",sans-serif;}</style>')
      ..writeln('<rect x="0" y="0" width="$size" height="$size" fill="$fillColor" stroke="$strokeColor" stroke-width="$stroke"/>')
      ..writeln('<rect x="$t" y="$t" width="${2 * t}" height="${2 * t}" fill="$fillColor" stroke="$strokeColor" stroke-width="$stroke"/>');

    // segmented verticals (skip center)
    for (final x in [t, 2 * t, 3 * t]) {
      sb.writeln('<line x1="$x" y1="0" x2="$x" y2="$t" stroke="$strokeColor" stroke-width="$stroke"/>');
      sb.writeln('<line x1="$x" y1="${3 * t}" x2="$x" y2="$size" stroke="$strokeColor" stroke-width="$stroke"/>');
    }
    // segmented horizontals (skip center)
    for (final y in [t, 2 * t, 3 * t]) {
      sb.writeln('<line x1="0" y1="$y" x2="$t" y2="$y" stroke="$strokeColor" stroke-width="$stroke"/>');
      sb.writeln('<line x1="${3 * t}" y1="$y" x2="$size" y2="$y" stroke="$strokeColor" stroke-width="$stroke"/>');
    }

    // --- CENTER TITLE (exact middle of the inner square) ---
    if (title != null && title.isNotEmpty) {
      sb.writeln(
        '<text x="${size / 2}" y="${size / 2}" '
            'text-anchor="middle" dominant-baseline="middle" '
            'font-weight="600" font-size="18" fill="#444">$title</text>',
      );
    }

    // --- Labels on the ring cells (multi-line, vertically centered) ---
    const labelFontSize = 14.0;
    const lineHeight = 16.0; // tune if you want tighter/looser stacking

    labels.forEach((cell, names) {
      final cx = (cell.left + cell.right) / 2;
      final cy = (cell.top + cell.bottom) / 2;

      // starting y so that N lines are centered around cy
      final firstY = cy - ((names.length - 1) * lineHeight / 2);

      final b = StringBuffer()
        ..writeln('<text x="$cx" y="$firstY" text-anchor="middle" '
            'font-weight="600" font-size="$labelFontSize" fill="#222">');

      for (int i = 0; i < names.length; i++) {
        final token = names[i].trim();
        if (i == 0) {
          b.writeln('<tspan x="$cx">$token</tspan>');
        } else {
          b.writeln('<tspan x="$cx" dy="$lineHeight">$token</tspan>');
        }
      }
      b.writeln('</text>');
      sb.write(b.toString());
    });

    sb.writeln('</svg>');
    return sb.toString();
  }

  /// Vendor sometimes returns nested JSON: {"output":"\"<svg ...>\""} etc.
  static String unwrapSvgPayload(dynamic body) {
    dynamic raw = (body is Map && body.containsKey('output')) ? body['output'] : body;
    for (int i = 0; i < 3; i++) {
      if (raw is String) {
        try { raw = jsonDecode(raw); } catch (_) { break; }
      }
    }
    if (raw is String) return raw;
    if (raw is Map && raw['svg'] is String) return raw['svg'] as String;
    return '';
  }

  /// Full pipeline: unwrap vendor body → extract labels → build clean SVG.
  static String rebuildCleanChartSvg(dynamic vendorBody, {String? title, double size = 400}) {
    final vendor = unwrapSvgPayload(vendorBody).trim();
    if (vendor.isEmpty) return '';
    final labels = extractRingLabels(vendor);
    return buildKattam12Svg(size: size, title: title, labels: labels);
  }
}
