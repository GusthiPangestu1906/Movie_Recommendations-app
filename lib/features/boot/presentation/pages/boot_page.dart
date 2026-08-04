import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      backgroundColor: const Color(0xFF0B0E1E),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BootLogo(),
                  const SizedBox(height: 40),
                  const BootProgressBar(),
                ],
              ),
            ),
          ),
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
