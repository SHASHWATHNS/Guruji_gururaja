import 'dart:math' as math;
import 'package:flutter/material.dart';

class TarotCardBackTile extends StatelessWidget {
  final String heroTag;
  final bool highlighted;
  final bool shuffling;
  final VoidCallback onTap;

  // NEW: drive per-tile animation
  final Animation<double>? shuffleProgress; // 0..1, can repeat
  final int? tileIndex; // for stagger & phase

  const TarotCardBackTile({
    super.key,
    required this.heroTag,
    required this.highlighted,
    required this.shuffling,
    required this.onTap,
    this.shuffleProgress,
    this.tileIndex,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = highlighted ? Theme.of(context).colorScheme.primary : Colors.black12;

    // If no animation passed, fall back to static tile
    if (shuffleProgress == null || tileIndex == null) {
      return _frame(borderColor, child: _ink(onTap));
    }

    return AnimatedBuilder(
      animation: shuffleProgress!,
      builder: (context, _) {
        final t = shuffleProgress!.value; // 0..1
        final idx = tileIndex!;

        // Stagger start/end per index (wave across the grid).
        // phase shifts distribute motion so it looks chaotic but smooth.
        final phase = (idx * 37) % 360; // cheap pseudo-random but stable
        final rad = (t * 2 * math.pi) + (phase * math.pi / 180);

        // Motion recipe (small and tasteful):
        final tilt = 0.04 * math.sin(rad);              // ± ~2.3°
        final scale = 0.98 + 0.02 * math.cos(rad);      // 0.98..1.00
        final dx = 1.5 * math.sin(rad * 1.3);           // ±1.5px
        final dy = 1.5 * math.cos(rad * 1.2);           // ±1.5px

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: tilt,
            child: Transform.scale(
              scale: scale,
              child: _frame(borderColor, child: _ink(onTap)),
            ),
          ),
        );
      },
    );
  }

  Widget _frame(Color borderColor, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: highlighted ? 2 : 1),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8, spreadRadius: 0, color: Colors.black26, offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _ink(VoidCallback onTap) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Hero(
          tag: heroTag,
          child: AspectRatio(
            aspectRatio: 2.5 / 4,
            child: Image.asset(
              'assets/tarot/back.jpg', // match your asset
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
