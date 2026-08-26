

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';

class CartIcon extends StatelessWidget {
  final int totalItemCount;
  const CartIcon({super.key, required this.totalItemCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          const Icon(LineIcons.shoppingCart, size: 28, color: Colors.black),

          if (totalItemCount > 0)
            Positioned(
              top: -9,
              right: -9,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    totalItemCount > 99 ? '99+' : totalItemCount.toString(),
                    style: AppFontStyle.caption.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
