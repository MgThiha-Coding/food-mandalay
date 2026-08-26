import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/category/data/category_list_notifier.dart';
import 'package:mandalar_x/features/home/data/product_list_notifier.dart';

class InternetOffWidget extends ConsumerWidget {
  const InternetOffWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 30),
          const SizedBox(height: 6),
          Text("You're offline.", style: AppFontStyle.label),
          const SizedBox(height: 3),
          TextButton(
            onPressed: () {
              ref.read(productListNotifierProvider.notifier).fetchProductList();
              ref
                  .read(categoryListNotifierProvider.notifier)
                  .fetchCategoryList();
            },
            child: Text('Retry', style: AppFontStyle.label),
          ),
        ],
      ),
    );
  }
}
