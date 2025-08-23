import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bright yellow strip with centered logo
        Container(
          width: double.infinity,
          color: const Color(0xFFFFD400), // bright yellow
          padding: const EdgeInsets.symmetric(vertical: 20),
          alignment: Alignment.center,
          child: CircleAvatar(
            radius: 100,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: const _LogoAssetOrFallback(size: 200),
            ),
          ),
        ),

        // Name on light yellow (matches page)
        Container(
          width: double.infinity,
          color: const Color(0xFFFFF3CD), // light yellow
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: const Text(
            'GURUJI GURURAJA',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoAssetOrFallback extends StatelessWidget {
  final double size;
  const _LogoAssetOrFallback({required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/face.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          width: size,
          height: size,
          color: Colors.white,
          alignment: Alignment.center,
          child: const Text(
            'GG',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
        );
      },
    );
  }
}
