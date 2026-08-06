import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoadingIndicator({super.key, this.size = 40.0, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          Image.asset(
                'assets/reel.png',
                width: size,
                height: size,
                color: color,
              )
              .animate(onPlay: (c) => c.repeat())
              .rotate(duration: 2.seconds, curve: Curves.linear),
    );
  }
}
