import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';

class CarouselSection extends StatelessWidget {
  final double screenHeight;
  const CarouselSection({super.key, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    final edgePadding = 12.0;

    final List<Widget> carouselItems = [
      _CarouselCard(
        title: 'Fast Delivery',
        subtitle: 'Fresh food from Mandalay',
        buttonText: 'Order Now',
        buttonColor: Colors.white,
        buttonTextColor: Colors.redAccent,
      ),
      _CarouselCard(
        title: 'Cheese Pizza',
        subtitle: 'Hot & cheesy deal today',
        imageAsset: 'assets/images/pizza.png',
      ),
    ];

    return Container(
      height: screenHeight * 0.16,
      color: AppColors.appBackground,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: edgePadding, vertical: 8),
        child: CarouselSlider(
          items: carouselItems,
          options: CarouselOptions(
            height: screenHeight * 0.20,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 400),
            enlargeCenterPage: false,
            scrollPhysics: const BouncingScrollPhysics(),
          ),
        ),
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageAsset;
  final IconData? icon;
  final String? buttonText;
  final Color? buttonColor;
  final Color? buttonTextColor;

  const _CarouselCard({
    required this.title,
    required this.subtitle,
    this.imageAsset,
    this.icon,
    this.buttonText,
    this.buttonColor,
    this.buttonTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.appBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFontStyle.label.copyWith(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: AppFontStyle.caption.copyWith(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.grey.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.red, size: 40),
              ),
            if (imageAsset != null)
              Image.asset(imageAsset!, height: 70, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }
}
