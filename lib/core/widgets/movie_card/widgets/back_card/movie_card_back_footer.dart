import 'package:flutter/material.dart';

class MovieCardBackFooter extends StatelessWidget {
  final String movieTitle;
  final bool isEditing;
  final VoidCallback onTapReturn;

  const MovieCardBackFooter({
    super.key,
    required this.movieTitle,
    required this.isEditing,
    required this.onTapReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 6),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white10, width: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              movieTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onTapReturn,
            child: Row(
              children: [
                Icon(
                  Icons.flip_to_front_rounded,
                  color: isEditing
                      ? const Color(0xFF8B95E5)
                      : Colors.greenAccent,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  isEditing ? 'Cancel' : 'Return',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
