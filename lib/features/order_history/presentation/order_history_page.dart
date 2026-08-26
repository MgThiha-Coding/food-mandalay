import 'package:flutter/widgets.dart';
import 'package:mandalar_x/core/responsive/app_responsive.dart';
import 'package:mandalar_x/features/order_history/presentation/desktop/order_history_page_desktop.dart';
import 'package:mandalar_x/features/order_history/presentation/mobile/order_history_page_mobile.dart';
import 'package:mandalar_x/features/order_history/presentation/tablet/order_history_page_tablet.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return AppResponsive(
      mobile: OrderHistoryPageMobile(),
      tablet: OrderHistoryPageTablet(),
      desktop: OrderHistoryPageDesktop(),
    );
  }
}