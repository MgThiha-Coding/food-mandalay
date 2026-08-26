import 'package:flutter/material.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';

class AppFontStyle {
  static const String _fontFamily = 'Poppins';

  static double appHorizontalPadding = 20;

  // home page [ right corner (delivery address)]
  static const TextStyle homeDeliveryAddress = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );

  // home page [ right corner ( animated search hint )]
  static const TextStyle animatedSearchHint = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle title = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle productName = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static const TextStyle productPrice = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.red,
  );

  static TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: AppColors.labelColor,
  );

  static TextStyle subtitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.black54,
  );
}
