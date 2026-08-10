import 'package:flutter/material.dart';

class MovieBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final Color? textColor;

  const MovieBadge({
    super.key,
    required this.icon,
    required this.text,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor ?? Colors.white30, size: 10),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor ?? Colors.white30,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
