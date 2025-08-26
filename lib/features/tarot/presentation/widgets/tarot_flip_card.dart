import 'package:flutter/material.dart';

class TarotFlipCard extends StatelessWidget {
  final Animation<double> flipAnim;
  final String backAsset;     // 'assets/tarot/back.png'
  final String frontAsset;    // e.g., 'assets/tarot/TARROT1.JPG'

  const TarotFlipCard({
    super.key,
    required this.flipAnim,
    required this.backAsset,
    required this.frontAsset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: flipAnim,
      builder: (context, child) {
        final showFront = flipAnim.value > 0.5;
        final angle = flipAnim.value * 3.1415926;

        final widgetToShow = showFront
            ? Image.asset(frontAsset, fit: BoxFit.cover)
            : Image.asset(backAsset, fit: BoxFit.cover);

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(showFront ? 3.1415926 : 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 2.5 / 4,
                child: widgetToShow,
              ),
            ),
          ),
        );
      },
    );
  }
}
