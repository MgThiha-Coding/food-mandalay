import 'package:flutter/material.dart';
import 'package:mandalar_x/core/responsive/app_responsive.dart';
import 'package:mandalar_x/features/checkout/presentation/desktop/check_out_page_desktop.dart';
import 'package:mandalar_x/features/checkout/presentation/mobile/check_out_page_mobile.dart';
import 'package:mandalar_x/features/checkout/presentation/tablet/check_out_page_tablet.dart';

class CheckOutPage extends StatefulWidget {
  const CheckOutPage({super.key});

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  @override
  Widget build(BuildContext context) {
    return AppResponsive(
      mobile: CheckOutPageMobile(),
      tablet: CheckOutPageTablet(),
      desktop: CheckOutPageDesktop(),
    );
  }
}
