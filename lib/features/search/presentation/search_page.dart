import 'package:flutter/material.dart';
import 'package:mandalar_x/core/responsive/app_responsive.dart';
import 'package:mandalar_x/features/search/presentation/desktop/search_page_desktop.dart';
import 'package:mandalar_x/features/search/presentation/mobile/search_page_mobile.dart';
import 'package:mandalar_x/features/search/presentation/tablet/search_page_tablet.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return AppResponsive(
       mobile: SearchPageMobile(),
       tablet: SearchPageTablet(),
       desktop: SearchPageDesktop(),
    );
  }
}