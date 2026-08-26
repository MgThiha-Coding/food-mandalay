import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_fonts.dart';
import 'package:mandalar_x/features/auth/presentation/continue_with_google_page.dart';
import 'package:mandalar_x/features/wrapper/wrapper_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final hasSession = Supabase.instance.client.auth.currentSession != null;
      if (hasSession) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WrapperPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ContinueWithGooglePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white70,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 80,
                backgroundImage: AssetImage('assets/images/app_logo.jpg'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextLoading extends StatefulWidget {
  const TextLoading({super.key});

  @override
  State<TextLoading> createState() => _MandalarXTextLoadingState();
}

class _MandalarXTextLoadingState extends State<TextLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.30, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) {
        return Opacity(
          opacity: _opacity.value,
          child: Text(
            "Food Mandalay",
            style: GoogleFonts.podkova(
              fontSize: AppFonts.titleLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.appBackground,
            ),
          ),
        );
      },
    );
  }
}
