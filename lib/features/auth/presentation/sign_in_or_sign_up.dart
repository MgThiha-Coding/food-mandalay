import 'package:flutter/material.dart';
import 'package:mandalar_x/features/auth/presentation/sign_in_page.dart';
import 'package:mandalar_x/features/auth/presentation/sign_up_page.dart';

class SignInOrSignup extends StatefulWidget {
  const SignInOrSignup({super.key});

  @override
  State<SignInOrSignup> createState() => _SignInOrSignupState();
}

class _SignInOrSignupState extends State<SignInOrSignup> {
  final PageController _controller = PageController(initialPage: 0);
  bool isLogin = true;

  void togglePage() {
    if (!_controller.hasClients) return;

    setState(() {
      isLogin = !isLogin;
      _controller.animateToPage(
        isLogin ? 0 : 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SignInPage(onTap: togglePage),
          SignUpPage(onTap: togglePage),
        ],
      ),
    );
  }
}
