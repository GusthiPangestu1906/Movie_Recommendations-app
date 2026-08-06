import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/boot_provider.dart';
import '../widgets/boot_logo.dart';
import '../widgets/boot_progress_bar.dart';

class BootPage extends StatefulWidget {
  final VoidCallback onComplete;
  const BootPage({super.key, required this.onComplete});

  @override
  State<BootPage> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BootProvider>().runBootSequence(widget.onComplete);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010203),
      body: Consumer<BootProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              // 1. Background & Texture
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF1A1D2E).withOpacity(0.2),
                        const Color(0xFF010203),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(painter: ScreenTexturePainter()),
              ),

              // 2. Konten Utama (Tengah Sempurna)
              Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BootLogo(),
                      const SizedBox(height: 48),
                      const BootProgressBar(),
                      const SizedBox(height: 24),

                      // Status Text dengan Kompensasi Padding (Standard Flutter way)
                      if (provider.status.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4.0,
                          ), // Seimbangkan letterSpacing 4
                          child: Text(
                            provider.status.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 9,
                              letterSpacing: 4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ).animate(key: ValueKey(provider.status)).fadeIn(),
                    ],
                  ),
                ),
              ),

              // 3. Footer (Bawah Sempurna)
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 2.0,
                        ), // Seimbangkan letterSpacing 2
                        child: Text(
                          'powered by',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.2),
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Image.asset(
                        'assets/nyx.png',
                        width: 60,
                        opacity: const AlwaysStoppedAnimation(0.4),
                      ),
                    ],
                  ).animate().fadeIn(delay: 1.seconds),
                ),
              ),

              // 4. Final Flash Transition
              if (provider.progress >= 0.98)
                Positioned.fill(
                  child: Container(
                    color: Colors.white,
                  ).animate().fadeIn(duration: 400.ms),
                ),
            ],
          );
        },
      ),
    );
  }
}

class ScreenTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.01);
    for (double i = 0; i < size.height; i += 3) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
