import 'package:flutter/material.dart';
import 'package:mandalar_x/core/responsive/app_responsive.dart';
import 'package:mandalar_x/features/cart/presentation/desktop/cart_page_desktop.dart';
import 'package:mandalar_x/features/cart/presentation/mobile/page/cart_page_mobile.dart';
import 'package:mandalar_x/features/cart/presentation/tablet/cart_page_tablet.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return AppResponsive(
      mobile: CartPageMobile(),
      tablet: CartPageTablet(),
      desktop: CartPageDesktop(),

    );
  }
}