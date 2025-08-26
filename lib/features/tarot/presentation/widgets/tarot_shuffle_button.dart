import 'package:flutter/material.dart';

class TarotShuffleButton extends StatelessWidget {
  final bool shuffling;
  final VoidCallback onPressed;
  const TarotShuffleButton({super.key, required this.shuffling, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: shuffling ? null : onPressed,
      icon: const Icon(Icons.shuffle),
      label: Text(shuffling ? 'Shuffling...' : 'Shuffle'),
    );
  }
}
