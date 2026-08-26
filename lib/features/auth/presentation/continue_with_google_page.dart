import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/core/consts/app_images.dart';
import 'package:mandalar_x/core/consts/app_space.dart';
import 'package:mandalar_x/core/consts/app_storage.dart';
import 'package:mandalar_x/features/auth/data/sign_in_notifier.dart';
import 'package:mandalar_x/features/auth/data/sign_up_notifier.dart';
import 'package:mandalar_x/features/auth/model/user_model.dart';
import 'package:mandalar_x/features/wrapper/wrapper_page.dart';
import 'package:mandalar_x/shared/app_button.dart';

class ContinueWithGooglePage extends ConsumerStatefulWidget {
  const ContinueWithGooglePage({super.key});

  @override
  ConsumerState<ContinueWithGooglePage> createState() =>
      _ContinueWithGooglePageState();
}

class _ContinueWithGooglePageState
    extends ConsumerState<ContinueWithGooglePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    ref
        .read(signInNotifierProvider.notifier)
        .signIn(UserModel(email: email, password: password));
  }

  @override
  Widget build(BuildContext context) {
    // Listen sign up (Google) changes
    ref.listen<AsyncValue<UserModel?>>(signUpNotifierProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (user) {
          if (user != null) {
            AppStorage.setLoggedIn(true);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const WrapperPage()),
            );
          }
        },
        error: (error, stack) {
          Fluttertoast.showToast(
            msg: "Something went wrong. Please try again.",
            backgroundColor: Colors.black87,
            textColor: Colors.white,
          );
        },
        loading: () {},
      );
    });

    // Listen email/password sign-in changes
    ref.listen<AsyncValue<UserModel?>>(signInNotifierProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (user) {
          if (user != null) {
            AppStorage.setLoggedIn(true);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const WrapperPage()),
            );
          }
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Something went wrong. Please try again',
                style: AppFontStyle.body,
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        loading: () {},
      );
    });

    final signInState = ref.watch(signInNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        const CircleAvatar(
                          radius: 56,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage(
                            'assets/images/app_logo.jpg',
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Title
                        Text(
                          'Sign in to your account',
                          textAlign: TextAlign.center,
                          style: AppFontStyle.body.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: AppFontStyle.label,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 12,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            hintText: "Email",
                            hintStyle: AppFontStyle.subtitle,
                            labelText: "Email",
                            labelStyle: AppFontStyle.label,
                            suffixIcon: const Icon(LineIcons.envelope),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Email required";
                            }
                            if (!value.contains('@')) {
                              return "Invalid email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpace.base),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          style: AppFontStyle.label,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 12,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            hintText: "Password",
                            hintStyle: AppFontStyle.subtitle,
                            labelText: "Password",
                            labelStyle: AppFontStyle.label,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? LineIcons.eye
                                    : LineIcons.eyeSlash,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password required";
                            } else if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpace.medium),

                        // Sign in button
                        SizedBox(
                          width: double.infinity,
                          height: AppSpace.buttonHeight2,
                          child: AppButton(
                            title: "Sign In",
                            onTap: _signIn,
                            isLoading: signInState.isLoading,
                            backgroundColor: AppColors.primaryColor,
                            labelColor: AppColors.secondaryButtonLabel,
                          ),
                        ),

                        const SizedBox(height: 20),
                        Text(
                          'or continue with',
                          textAlign: TextAlign.center,
                          style: AppFontStyle.body.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Google Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            onPressed: () {
                              ref
                                  .read(signUpNotifierProvider.notifier)
                                  .signInWithGoogle();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(AppImages.googleLogo, height: 30),
                                const SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: AppFontStyle.label.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Food Mandalay © 2026',
                          style: AppFontStyle.caption.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            /*
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Food Mandalay © 2026',
                  style: AppFontStyle.caption.copyWith(color: Colors.grey),
                ),
              ),
            ),
            */
          ],
        ),
      ),
    );
  }
}
