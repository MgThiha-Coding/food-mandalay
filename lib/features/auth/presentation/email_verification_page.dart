import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_fonts.dart';
import 'package:mandalar_x/core/consts/app_space.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/wrapper/wrapper_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  final String? email;
  const EmailVerificationPage({this.email, super.key});

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  bool _isLoading = false;
  String? _message;

  /// Resend verification email
  Future<void> _resendVerification() async {
    final email =
        widget.email ?? Supabase.instance.client.auth.currentUser?.email;
    if (email == null) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.supabase.flutter://login-callback',
      );

      setState(() {
        _message =
            "Verification email sent! Please check your inbox (and spam folder).";
      });
    } catch (e) {
      setState(() {
        _message = "Failed to send verification email: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Check if user has verified their email
  Future<void> _checkVerification() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      await Supabase.instance.client.auth.refreshSession();

      if (user?.emailConfirmedAt != null) {
        // Email confirmed → navigate to wrapper/home page
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WrapperPage()),
          );
        }
      } else {
        setState(() {
          _message = "Email not verified yet. Please check your inbox.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error checking verification: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.medium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Verify Your Email', style: AppFontStyle.title),
              const SizedBox(height: AppSpace.large),
              Text(
                widget.email ?? 'No email provided',
                style: AppFontStyle.subtitle,
              ),
              const SizedBox(height: AppSpace.medium),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _message!,
                    style: AppFontStyle.caption.copyWith(
                      color: AppColors.primaryAction,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: AppSpace.medium),
              SizedBox(
                width: double.infinity,
                height: AppSpace.buttonHeight2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resendVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryAction,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Resend Verification Email',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: AppFonts.caption,
                            color: AppColors.secondaryButtonLabel,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpace.base),
              SizedBox(
                width: double.infinity,
                height: AppSpace.buttonHeight2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAction,
                  ),
                  child: const Text(
                    'I Have Verified My Email',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: AppFonts.caption,
                      color: AppColors.secondaryButtonLabel,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
