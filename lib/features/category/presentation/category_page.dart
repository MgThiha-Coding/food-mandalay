import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/responsive/app_responsive.dart';
import 'package:mandalar_x/features/category/presentation/desktop/category_page_desktop.dart';
import 'package:mandalar_x/features/category/presentation/mobile/category_page_mobile.dart';
import 'package:mandalar_x/features/category/presentation/tablet/category_page_tablet.dart';

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return AppResponsive(
       mobile: CategoryPageMobile(),
       tablet: CategoryPageTablet(),
       desktop: CategoryPageDesktop(),
    );

  }
}