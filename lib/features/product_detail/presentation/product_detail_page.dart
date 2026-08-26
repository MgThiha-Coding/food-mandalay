import 'package:flutter/material.dart';
import 'package:mandalar_x/core/responsive/app_responsive.dart';
import 'package:mandalar_x/features/product_detail/presentation/mobile/pages/product_detail_page_mobile.dart';
import 'package:mandalar_x/features/product_detail/presentation/tablet/product_detail_page_tablet.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  Widget build(BuildContext context) {
    return AppResponsive(
      mobile: ProductDetailPageMobile(),
      tablet: ProductDetailPageTablet(),
      desktop: ProductDetailPageTablet(),
    );
  }
}
