import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MenuButton extends StatelessWidget {
  final String text;
  final bool highlighted;
  final VoidCallback? onTap;
  const MenuButton({
    super.key,
    required this.text,
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = Border.all(color: AppColors.goldLine, width: 1.4);
    final radius = BorderRadius.circular(6);

    return Material(
      color: highlighted ? AppColors.primary : AppColors.tileBg,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: border,
            borderRadius: radius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: highlighted ? Colors.white : AppColors.tileText,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
