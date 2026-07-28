import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  Offset position;
  Offset velocity;
  double size;
  double opacity;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
  });

  void update(Offset mousePos, Size canvasSize) {
    // Attraction to mouse
    double dx = mousePos.dx - position.dx;
    double dy = mousePos.dy - position.dy;
    double distance = sqrt(dx * dx + dy * dy);

    if (distance < 250) {
      double force = (250 - distance) / 250;
      velocity += Offset(dx * force * 0.02, dy * force * 0.02);
    }

    // Friction
    velocity *= 0.95;

    // Movement
    position += velocity;

    // Random jitter
    position += Offset((Random().nextDouble() - 0.5) * 0.5, (Random().nextDouble() - 0.5) * 0.5);

    // Screen wrap
    if (position.dx < 0) position = Offset(canvasSize.width, position.dy);
    if (position.dx > canvasSize.width) position = Offset(0, position.dy);
    if (position.dy < 0) position = Offset(position.dx, canvasSize.height);
    if (position.dy > canvasSize.height) position = Offset(position.dx, 0);
  }
}

class ParticleBackground extends StatefulWidget {
  final Widget? child;
  const ParticleBackground({super.key, this.child});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  Offset _mousePosition = const Offset(-1000, -1000);
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Inisialisasi partikel setelah layout pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initParticles();
    });
  }

  void _initParticles() {
    final size = MediaQuery.of(context).size;
    for (int i = 0; i < 60; i++) {
      _particles.add(Particle(
        position: Offset(
          _random.nextDouble() * size.width,
          _random.nextDouble() * size.height,
        ),
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 2,
          (_random.nextDouble() - 0.5) * 2,
        ),
        size: _random.nextDouble() * 2 + 1,
        opacity: _random.nextDouble() * 0.4 + 0.1,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          _mousePosition = event.localPosition;
        });
      },
      onExit: (_) {
        setState(() {
          _mousePosition = const Offset(-1000, -1000);
        });
      },
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final canvasSize = MediaQuery.of(context).size;
              for (var p in _particles) {
                p.update(_mousePosition, canvasSize);
              }
              return CustomPaint(
                size: Size.infinite,
                painter: ParticlePainter(particles: _particles, mousePos: _mousePosition),
              );
            },
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Offset mousePos;
  ParticlePainter({required this.particles, required this.mousePos});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (var p in particles) {
      // Draw particle
      paint.color = const Color(0xFF4A56E2).withOpacity(p.opacity);
      canvas.drawCircle(p.position, p.size, paint);

      // Draw lines between particles
      for (var other in particles) {
        double dist = (p.position - other.position).distance;
        if (dist < 120) {
          paint.color = const Color(0xFF4A56E2).withOpacity(0.15 * (1 - dist / 120));
          paint.strokeWidth = 0.5;
          canvas.drawLine(p.position, other.position, paint);
        }
      }

      // Draw lines to mouse
      double distToMouse = (p.position - mousePos).distance;
      if (distToMouse < 200) {
        paint.color = Colors.blueAccent.withOpacity(0.3 * (1 - distToMouse / 200));
        paint.strokeWidth = 1.0;
        canvas.drawLine(p.position, mousePos, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
