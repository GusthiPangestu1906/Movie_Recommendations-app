import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BootLogo extends StatelessWidget {
  const BootLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Logo Reel dengan Koreksi Rotasi & Efek Glow
        Stack(
          alignment: Alignment.center,
          children: [
            // Cahaya di belakang
            Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF5C6AC4).withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .scale(
                  duration: 3.seconds,
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.3, 1.3),
                )
                .fadeOut(duration: 3.seconds),

            // Logo Reel Utama dengan rotasi halus agar terlihat "lurus"
            Transform.rotate(
                  angle:
                      0.15, // Putar sedikit searah jarum jam untuk meluruskan blade kipas
                  child: Image.asset(
                    'assets/reel.png',
                    width: 110,
                    height: 110,
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(
                  begin: const Offset(0.9, 0.9),
                  curve: Curves.easeOutBack,
                ),
          ],
        ),

        const SizedBox(height: 20),

        // 2. Nama Brand "nyxdex" (Presisi Center)
        // Menggunakan teknik Text.rich agar spasi tidak ada di huruf terakhir
        Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'nyxde', style: TextStyle(letterSpacing: 8)),
                  TextSpan(text: 'x'),
                ],
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 800.ms)
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }
}
