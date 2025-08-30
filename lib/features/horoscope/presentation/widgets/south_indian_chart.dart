import 'package:flutter/material.dart';

/// South-Indian style chart (12 houses around an empty center).
/// [houses] map: 1..12 -> list of strings to show inside each house.
/// [startAtPosition]: which visual cell (0..11) should be treated as House 1.
///   0 = top-left (default), 1 = top-second (your request), then clockwise.
class SouthIndianChart extends StatelessWidget {
  final String title;
  final Map<int, List<String>>? houses;
  final Color accent;
  final EdgeInsets padding;
  final int startAtPosition; // <-- NEW

  const SouthIndianChart({
    super.key,
    required this.title,
    this.houses,
    this.accent = const Color(0xFF8E6C3A),
    this.padding = const EdgeInsets.all(16),
    this.startAtPosition = 0, // default = top-left is House 1
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.colorScheme.surface.withOpacity(0.98);
    final border = theme.dividerColor.withOpacity(.35);

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent.withOpacity(.12), accent.withOpacity(.05)],
                ),
                border: Border.all(color: accent.withOpacity(.22)),
              ),
              child: Row(
                children: [
                  Icon(Icons.grid_view_rounded, size: 18, color: accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // CHART SQUARE
            AspectRatio(
              aspectRatio: 1,
              child: LayoutBuilder(
                builder: (context, c) {
                  final stroke = 1.4;
                  final fg = border;
                  final bg = theme.colorScheme.surface;
                  final subtle = accent.withOpacity(.06);

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // background
                        Container(
                          decoration: BoxDecoration(
                            color: bg,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.surface.withOpacity(.96),
                                theme.colorScheme.surfaceVariant.withOpacity(.32),
                              ],
                            ),
                          ),
                        ),

                        // grid lines
                        CustomPaint(
                          painter: _SouthIndianLinesPainter(
                            color: fg,
                            stroke: stroke,
                            centerFill:
                            theme.colorScheme.surface.withOpacity(.94),
                          ),
                        ),

                        // labels
                        _HouseLabels(
                          houses: houses,
                          accent: accent,
                          subtleFill: subtle,
                          textColor: theme.colorScheme.onSurface,
                          startAtPosition: startAtPosition, // <-- pass
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SouthIndianLinesPainter extends CustomPainter {
  final Color color;
  final double stroke;
  final Color centerFill;

  _SouthIndianLinesPainter({
    required this.color,
    required this.stroke,
    required this.centerFill,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final w = size.width, h = size.height;
    final qx = w / 4, qy = h / 4;

    // Outer border
    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(10),
    );
    canvas.drawRRect(outer, paint);

    // Center square
    final centerRect = Rect.fromLTWH(qx, qy, 2 * qx, 2 * qy);
    final centerFillPaint = Paint()
      ..color = centerFill
      ..style = PaintingStyle.fill;
    canvas.drawRect(centerRect, centerFillPaint);

    // Top & bottom small cells
    canvas.drawLine(Offset(qx, 0), Offset(qx, qy), paint);
    canvas.drawLine(Offset(2 * qx, 0), Offset(2 * qx, qy), paint);
    canvas.drawLine(Offset(3 * qx, 0), Offset(3 * qx, qy), paint);

    canvas.drawLine(Offset(qx, 3 * qy), Offset(qx, h), paint);
    canvas.drawLine(Offset(2 * qx, 3 * qy), Offset(2 * qx, h), paint);
    canvas.drawLine(Offset(3 * qx, 3 * qy), Offset(3 * qx, h), paint);

    // Left & right small cells
    canvas.drawLine(Offset(0, qy), Offset(qx, qy), paint);
    canvas.drawLine(Offset(0, 3 * qy), Offset(qx, 3 * qy), paint);
    canvas.drawLine(Offset(3 * qx, qy), Offset(w, qy), paint);
    canvas.drawLine(Offset(3 * qx, 3 * qy), Offset(w, 3 * qy), paint);

    // Inner square border
    canvas.drawRect(centerRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HouseLabels extends StatelessWidget {
  final Map<int, List<String>>? houses;
  final Color accent;
  final Color subtleFill;
  final Color textColor;
  final int startAtPosition; // <-- NEW

  const _HouseLabels({
    required this.houses,
    required this.accent,
    required this.subtleFill,
    required this.textColor,
    required this.startAtPosition,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth, h = c.maxHeight;
      final qx = w / 4, qy = h / 4;

      // 12 visual rects in clockwise order starting from TOP-LEFT
      final rects = <Rect>[
        Rect.fromLTWH(0, 0, qx, qy),
        Rect.fromLTWH(qx, 0, qx, qy),
        Rect.fromLTWH(2 * qx, 0, qx, qy),
        Rect.fromLTWH(3 * qx, 0, qx, qy),
        Rect.fromLTWH(3 * qx, qy, qx, qy),
        Rect.fromLTWH(3 * qx, 2 * qy, qx, qy),
        Rect.fromLTWH(3 * qx, 3 * qy, qx, qy),
        Rect.fromLTWH(2 * qx, 3 * qy, qx, qy),
        Rect.fromLTWH(qx, 3 * qy, qx, qy),
        Rect.fromLTWH(0, 3 * qy, qx, qy),
        Rect.fromLTWH(0, 2 * qy, qx, qy),
        Rect.fromLTWH(0, qy, qx, qy),
      ];

      // position -> house number mapping with an offset:
      // House 1 lives at visual index = startAtPosition
      int houseNoForPosition(int pos) =>
          ((pos - startAtPosition + 12) % 12) + 1;

      return Stack(
        children: List.generate(12, (i) {
          final houseNo = houseNoForPosition(i);
          final r = rects[i].deflate(6);
          final items = (houses?[houseNo] ?? const <String>[])
              .where((e) => e.trim().isNotEmpty)
              .toList();

          return Positioned.fromRect(
            rect: r,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // house index chip
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: subtleFill,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: accent.withOpacity(.2)),
                    ),
                    child: Text(
                      '$houseNo',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: textColor.withOpacity(.75),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // contents
                  if (items.isEmpty)
                    Text('—',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(.45),
                        ))
                  else
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: items
                          .map(
                            (t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: subtleFill,
                            border:
                            Border.all(color: accent.withOpacity(.25)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            t,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: textColor.withOpacity(.9),
                              height: 1.05,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                ],
              ),
            ),
          );
        }),
      );
    });
  }
}
