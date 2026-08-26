import 'package:flutter/widgets.dart';
import 'package:mandalar_x/core/responsive/app_responsive.dart';
import 'package:mandalar_x/features/explore/presentation/desktop/explore_page_desktop.dart';
import 'package:mandalar_x/features/explore/presentation/mobile/explore_page_mobile.dart';
import 'package:mandalar_x/features/explore/presentation/tablet/explore_page_tablet.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return AppResponsive(
      mobile: ExplorePageMobile(),
      tablet: ExplorePageTablet(),
      desktop: ExplorePageDesktop(),
    );
  }
}
