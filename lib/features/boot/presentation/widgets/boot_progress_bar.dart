import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/boot_provider.dart';

class BootProgressBar extends StatelessWidget {
  const BootProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BootProvider>(
      builder: (context, provider, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        // Gunakan lebar yang pasti (65% screen atau max 320)
        final barWidth = screenWidth > 500 ? 320.0 : screenWidth * 0.65;

        return SizedBox(
          width: barWidth,
          height: 2,
          child: Stack(
            children: [
              // Track (Background)
              Container(
                width: barWidth,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              // Fill (Progress)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: barWidth * provider.progress,
                height: 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4A56E2),
                      Color(0xFF5C6AC4),
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A56E2).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
