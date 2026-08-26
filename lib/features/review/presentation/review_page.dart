import 'package:flutter/material.dart';
import 'package:mandalar_x/core/responsive/app_responsive.dart';
import 'package:mandalar_x/features/review/presentation/desktop/review_page_desktop.dart';
import 'package:mandalar_x/features/review/presentation/mobile/review_page_mobile.dart';
import 'package:mandalar_x/features/review/presentation/tablet/review_page_tablet.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  Widget build(BuildContext context) {
    return AppResponsive(
       mobile: ReviewPageMobile(),
       tablet: ReviewPageTablet(),
       desktop: ReviewPageDesktop(),
    );
  }
}