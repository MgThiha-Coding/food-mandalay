import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';

class MandalarXTextLoading extends StatefulWidget {
  const MandalarXTextLoading({super.key});

  @override
  State<MandalarXTextLoading> createState() => _MandalarXTextLoadingState();
}

class _MandalarXTextLoadingState extends State<MandalarXTextLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.35, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Center(
        child: AnimatedBuilder(
          animation: _opacity,
          builder: (_, __) {
            return Opacity(
              opacity: _opacity.value,
              child: Text(
                "Food Mandalay",
                style: GoogleFonts.podkova(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                  letterSpacing: 1.2,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
