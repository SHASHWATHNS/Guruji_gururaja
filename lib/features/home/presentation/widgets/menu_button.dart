import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final TextStyle? textStyle;

  const MenuButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.textStyle,
  });

  bool _isTamil(String s) => RegExp(r'[\u0B80-\u0BFF]').hasMatch(s);

  @override
  Widget build(BuildContext context) {
    // Default font size
    double fontSize = 15;

    // Shrink ONLY for this specific Tamil label
    if (_isTamil(label) && label.trim() == 'எங்களைப் பற்றி தகவல்') {
      fontSize = 13; // adjust to your taste (12–14 works well)
    }

    return Material(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
