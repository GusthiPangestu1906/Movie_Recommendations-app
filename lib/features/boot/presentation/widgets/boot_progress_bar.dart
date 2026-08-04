import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/boot_provider.dart';

class BootProgressBar extends StatelessWidget {
  const BootProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 600 ? 400.0 : screenWidth - 80.0;

    return Consumer<BootProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          width: contentWidth,
          child: Column(
            children: [
              Stack(
                children: [
                  // Track
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Fill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 4,
                    width: contentWidth * provider.progress,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A56E2), Color(0xFF5C6AC4)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A56E2).withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Status Message
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  provider.statusMessage,
                  key: ValueKey(provider.statusMessage),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
