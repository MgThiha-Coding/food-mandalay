import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/core/consts/app_fonts.dart';
import 'package:mandalar_x/core/consts/app_space.dart';
import 'package:mandalar_x/core/consts/app_storage.dart';
import 'package:mandalar_x/features/auth/data/sign_in_notifier.dart';
import 'package:mandalar_x/features/auth/model/user_model.dart';
import 'package:mandalar_x/features/wrapper/wrapper_page.dart';
import 'package:mandalar_x/shared/app_button.dart';

class SignInPage extends ConsumerStatefulWidget {
  final VoidCallback? onTap;
  const SignInPage({super.key, this.onTap});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  bool _passwordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void signIn() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    ref
        .read(signInNotifierProvider.notifier)
        .signIn(UserModel(email: email, password: password));
  }

  @override
  Widget build(BuildContext context) {
    final signInState = ref.watch(signInNotifierProvider);
    ref.listen<AsyncValue<UserModel?>>(signInNotifierProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (user) {
          if (user != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WrapperPage()),
            );
            AppStorage.setLoggedIn(true);
          }
        },
        error: (error, stack) {
         ScaffoldMessenger.of(context).showSnackBar(
            
            SnackBar(
             
              content: Text('Somethin went wrong.Please try again', style: AppFontStyle.body),
              duration: Duration(seconds: 2),
            ),
          );
        },
        loading: () {},
      );
    });
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.appGradientTop,
              AppColors.appGradientMiddle,
              AppColors.appGradientBottom,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Food Mandalay',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: AppFonts.titleLarge,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpace.tiny),
                    Text(
                      'All your favourite is here',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: AppFonts.bodySmall,
                        color: AppColors.primaryButtonLabel,
                      ),
                    ),
                    /*
                    const SizedBox(height: AppSpace.large),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: Size(
                          double.infinity,
                          AppSpace.buttonHeight2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue with Google',
                            style: AppFontStyle.label,
                          ),
                          const SizedBox(width: 8),
                          Image.asset(AppImages.googleLogo, scale: 12),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSpace.medium),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('or', style: AppFontStyle.caption),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                      ],
                    ),
                    */
                    const SizedBox(height: AppSpace.medium),
                    TextFormField(
                      controller: _emailController,
                      style: AppFontStyle.label,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 12,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: "Email",
                        hintStyle: AppFontStyle.subtitle,
                        labelText: "Email",
                        labelStyle: AppFontStyle.label,
                        suffixIcon: Icon(LineIcons.envelope),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpace.base),
                    TextFormField(
                      controller: _passwordController,
                      style: AppFontStyle.label,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
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
                    SizedBox(
                      width: double.infinity,
                      height: AppSpace.buttonHeight2,
                      child: AppButton(
                        title: "Sign In",
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            signIn();
                          }
                        },
                        isLoading: signInState.isLoading,
                        backgroundColor: AppColors.primaryColor,
                        labelColor: AppColors.secondaryButtonLabel,
                      ),
                    ),
                    const SizedBox(height: AppSpace.large),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: AppFontStyle.caption,
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 12,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
