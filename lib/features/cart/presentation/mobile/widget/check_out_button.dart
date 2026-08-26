
import 'package:flutter/material.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/checkout/presentation/check_out_page.dart';

class CheckOutButton extends StatelessWidget {
  final double totalPrice;
  const CheckOutButton({super.key, required this.totalPrice});
  String getFormattedPrice(double? price) {
    if (price == null) return '';
    return price.truncateToDouble() == price
        ? price.toInt().toString()
        : price.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 90,
        width: double.infinity,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Price', style: AppFontStyle.label),
                Text(
                  'MMK ${getFormattedPrice(totalPrice)}',
                  style: AppFontStyle.label.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CheckOutPage()),
                  );
                },
                child: Text(
                  'Check Out',
                  style: AppFontStyle.label.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.appBackground,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}