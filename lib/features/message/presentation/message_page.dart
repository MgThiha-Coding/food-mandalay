import 'package:flutter/material.dart';
import 'package:mandalar_x/core/responsive/app_responsive.dart';
import 'package:mandalar_x/features/message/presentation/desktop/message_page_desktop.dart';
import 'package:mandalar_x/features/message/presentation/mobile/message_page_mobile.dart';
import 'package:mandalar_x/features/message/presentation/tablet/message_page_tablet.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    return AppResponsive(
      mobile: MessagePageMobile(),
      tablet: MessagePageTablet(),
      desktop: MessagePageDesktop(),
    );
  }
}
