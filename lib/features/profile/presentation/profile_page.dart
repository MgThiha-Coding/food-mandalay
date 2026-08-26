import 'package:flutter/material.dart';
import 'package:mandalar_x/core/responsive/app_responsive.dart';
import 'package:mandalar_x/features/profile/presentation/desktop/profile_page_desktop.dart';
import 'package:mandalar_x/features/profile/presentation/mobile/profile_page_mobile.dart';
import 'package:mandalar_x/features/profile/presentation/tablet/profile_page_tablet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return AppResponsive(
       mobile: ProfilePageMobile(),
       tablet: ProfilePageTablet(),
       desktop: ProfilePageDesktop(),
    );
  }
}