import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Full visible rectangular banner image
        Image.asset(
          'assets/images/header.PNG',
          width: double.infinity,
          fit: BoxFit.contain, // ensures full image is visible
        ),
      ],
    );
  }
}
