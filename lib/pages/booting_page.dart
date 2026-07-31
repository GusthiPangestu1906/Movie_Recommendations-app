import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BootingPage extends StatefulWidget {
  final VoidCallback onComplete;
  const BootingPage({super.key, required this.onComplete});

  @override
  State<BootingPage> createState() => _BootingPageState();
}

class _BootingPageState extends State<BootingPage> {
  double _progress = 0.0;
  String _statusMessage = "Starting...";

  final List<Map<String, dynamic>> _steps = [
    {"progress": 0.2, "message": "Starting..."},
    {"progress": 0.4, "message": "Loading..."},
    {"progress": 0.7, "message": "Syncing..."},
    {"progress": 1.0, "message": "Ready!"},
  ];

  @override
  void initState() {
    super.initState();
    _runBootSequence();
  }

  Future<void> _runBootSequence() async {
    for (var step in _steps) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() {
          _progress = (step["progress"] as num).toDouble();
          _statusMessage = step["message"] as String;
        });
      }
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 600 ? 400.0 : screenWidth - 80.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1E),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Membuat kolom seukuran konten untuk centering sempurna
                children: [
                  // Logo
                  Image.asset('assets/Group 3.png', width: 90, height: 90)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        duration: 1500.ms,
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.05, 1.05),
                        curve: Curves.easeInOut,
                      ),

                  const SizedBox(height: 16),

                  // Nama Aplikasi
                  const Text(
                    "MY MOVIES",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  ).animate().fadeIn(duration: 800.ms),

                  const SizedBox(height: 40),

                  // Container untuk Progress Bar dan Status
                  SizedBox(
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
                              width: contentWidth * _progress,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4A56E2),
                                    Color(0xFF5C6AC4),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4A56E2,
                                    ).withOpacity(0.3),
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
                            _statusMessage,
                            key: ValueKey(_statusMessage),
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
                  ),
                ],
              ),
            ),
          ),

          // Informasi Versi di paling bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Text(
                "SECURE BOOT v1.0.0",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.05),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
