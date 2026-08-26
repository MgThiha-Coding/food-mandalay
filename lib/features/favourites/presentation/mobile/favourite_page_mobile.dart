import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/favourites/data/favourite_notifier.dart';
import 'package:mandalar_x/features/home/data/product_list_notifier.dart';
import 'package:mandalar_x/features/product_detail/presentation/mobile/pages/product_detail_page_mobile.dart';

class FavouritePageMobile extends ConsumerWidget {
  const FavouritePageMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favouritesAsync = ref.watch(favouriteNotifierProvider);
    final productListAsync = ref.watch(productListNotifierProvider);
    final productList = productListAsync.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        title: Text(
          "Favourites",
          style: AppFontStyle.subtitle.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: favouritesAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Text(
                "No favourites yet",
                style: AppFontStyle.body.copyWith(color: Colors.grey),
              ),
            );
          }

          final favouriteProducts = list
              .map((fav) {
                return productList.firstWhere(
                  (p) => p.productId == fav.targetId,
                  orElse: () => null as dynamic,
                );
              })
              .whereType<dynamic>()
              .toList();

          if (favouriteProducts.isEmpty) {
            return Center(
              child: Text(
                "No favourite products found",
                style: AppFontStyle.body.copyWith(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: favouriteProducts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = favouriteProducts[index];
              final img = product.productImage;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailPageMobile(productId: product.productId),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: img != null
                            ? Image.network(
                                img,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade200,
                                child: Center(child: Text("No Image")),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName ?? '',
                              style: AppFontStyle.subtitle.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "MMK ${product.price?.toInt() ?? '0'}",
                              style: AppFontStyle.subtitle.copyWith(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ref
                              .read(favouriteNotifierProvider.notifier)
                              .toggleFavourite(
                                targetId: product.productId!,
                                targetType: 'item',
                              );
                        },
                        icon: Icon(Icons.favorite, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text("Failed to load favourites")),
      ),
    );
  }
}
