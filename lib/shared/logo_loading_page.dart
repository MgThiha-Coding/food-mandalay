import 'dart:math';

import 'package:flutter/material.dart';

class LogoLoadingPage extends StatefulWidget {
  const LogoLoadingPage({super.key});

  @override
  State<LogoLoadingPage> createState() => _LogoLoadingPageState();
}

class _LogoLoadingPageState extends State<LogoLoadingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double logoSize = 90;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: logoSize + 24,
          height: logoSize + 24,
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// Rotating loading ring
              AnimatedBuilder(
                animation: _controller,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2 * pi,
                    child: child,
                  );
                },
                child: CustomPaint(
                  size: const Size(114, 114),
                  painter: _LoadingRingPainter(color: Colors.blueAccent),
                ),
              ),

              /// Logo circle
              Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/app_logo.jpg'),
                    fit: BoxFit.contain,
                  ),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingRingPainter extends CustomPainter {
  final Color color;

  _LoadingRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final rect = Offset.zero & size;

    canvas.drawArc(
      rect.deflate(6),
      0,
      1.6 * pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
