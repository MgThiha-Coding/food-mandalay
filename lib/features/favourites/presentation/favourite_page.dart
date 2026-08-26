import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/responsive/app_responsive.dart';
import 'package:mandalar_x/features/favourites/presentation/desktop/favourite_page_desktop.dart';
import 'package:mandalar_x/features/favourites/presentation/mobile/favourite_page_mobile.dart';
import 'package:mandalar_x/features/favourites/presentation/tablet/favourite_page_tablet.dart';

class FavouritePage extends ConsumerStatefulWidget {
  const FavouritePage({super.key});

  @override
  ConsumerState<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends ConsumerState<FavouritePage> {
  @override
  Widget build(BuildContext context) {
    return AppResponsive(
      mobile: FavouritePageMobile(),
      tablet: FavouritePageTablet(),
      desktop: FavouritePageDesktop(),
    );
  }
}
