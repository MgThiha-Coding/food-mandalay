import 'package:flutter/material.dart';

class AppResponsive extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;

  const AppResponsive({super.key, this.mobile, this.tablet, this.desktop});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      // Mobile layout
      return mobile ?? const SizedBox();
    } else if (screenWidth >= 600 && screenWidth < 1200) {
      // Tablet layout
      //return tablet ?? mobile ?? const SizedBox();
      return mobile?? const SizedBox();
    } else {
      // Desktop layout
      //return desktop ?? tablet ?? mobile ?? const SizedBox();
      return mobile?? const SizedBox();
    }
  }
}
