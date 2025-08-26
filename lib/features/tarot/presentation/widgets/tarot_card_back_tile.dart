import 'package:flutter/material.dart';

class TarotCardBackTile extends StatelessWidget {
  final String heroTag;
  final bool highlighted;
  final bool shuffling;
  final VoidCallback onTap;

  const TarotCardBackTile({
    super.key,
    required this.heroTag,
    required this.highlighted,
    required this.shuffling,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = highlighted ? Theme.of(context).colorScheme.primary : Colors.black12;

    return AnimatedScale(
      scale: shuffling ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: AnimatedRotation(
        turns: shuffling ? 0.01 : 0.0, // small tilt during shuffle
        duration: const Duration(milliseconds: 250),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: highlighted ? 2 : 1),
            boxShadow: const [BoxShadow(blurRadius: 8, spreadRadius: 0, color: Colors.black26, offset: Offset(0, 3))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: onTap,
              child: Hero(
                tag: heroTag,
                child: AspectRatio(
                  aspectRatio: 2.5 / 4,
                  child: Image.asset(
                    'assets/tarot/back.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
