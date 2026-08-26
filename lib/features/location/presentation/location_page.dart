import 'package:flutter/material.dart';
import 'package:mandalar_x/core/responsive/app_responsive.dart';
import 'package:mandalar_x/features/location/presentation/desktop/location_page_desktop.dart';
import 'package:mandalar_x/features/location/presentation/mobile/location_page_mobile.dart';
import 'package:mandalar_x/features/location/presentation/tablet/location_page_tablet.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  @override
  Widget build(BuildContext context) {
    return AppResponsive(
      mobile: LocationPageMobile(),
      tablet: LocationPageTablet(),
      desktop: LocationPageDesktop(),
    );
  }
}
