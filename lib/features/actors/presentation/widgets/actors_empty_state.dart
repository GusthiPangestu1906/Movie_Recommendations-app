import 'package:flutter/material.dart';

class ActorsEmptyState extends StatelessWidget {
  final bool isListEmpty;

  const ActorsEmptyState({super.key, required this.isListEmpty});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_outline_rounded,
              size: 80,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isListEmpty ? 'No Stars in Your Galaxy' : 'No matches found',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isListEmpty
                ? 'Add your favorite actors to see them here!'
                : 'Try searching with a different name',
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
