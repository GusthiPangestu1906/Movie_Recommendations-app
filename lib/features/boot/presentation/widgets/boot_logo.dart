import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BootLogo extends StatelessWidget {
  const BootLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/Group 3.png', width: 90, height: 90)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              duration: 1500.ms,
              begin: const Offset(0.95, 0.95),
              end: const Offset(1.05, 1.05),
              curve: Curves.easeInOut,
            ),
        const SizedBox(height: 16),
        const Text(
          "MY MOVIES",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
          ),
        ).animate().fadeIn(duration: 800.ms),
      ],
    );
  }
}
