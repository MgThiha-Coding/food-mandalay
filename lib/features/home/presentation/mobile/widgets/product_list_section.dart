import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/favourites/data/favourite_notifier.dart';
import 'package:mandalar_x/features/product_detail/presentation/mobile/pages/product_detail_page_mobile.dart';

class ProductListSection extends ConsumerStatefulWidget {
  final List productList;
  const ProductListSection({super.key, required this.productList});

  @override
  ConsumerState<ProductListSection> createState() => _ProductListSectionState();
}

class _ProductListSectionState extends ConsumerState<ProductListSection> {
  void showCustomToast(
    BuildContext context,
    String message, {
    bool success = true,
  }) {
    final fToast = FToast();
    fToast.init(context);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6), // less rounded
        color: success ? Colors.black87 : Colors.red,
      ),
      child: Text(
        message,
        style: AppFontStyle.body.copyWith(
          fontFamily: 'Poppins',
          fontSize: 14, // medium size
          color: Colors.white,
        ),
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  String getFormattedPrice(double? price) {
    if (price == null) return '';
    return price.truncateToDouble() == price
        ? price.toInt().toString()
        : price.toString();
  }

  @override
  Widget build(BuildContext context) {
    final favouritesAsync = ref.watch(favouriteNotifierProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: ListView.builder(
        itemCount: widget.productList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final product = widget.productList[index];
          final img = product.productImage;
          final shopName = product.supplierName;
          final productId = product.productId;

          final relatedProductIsFavourited = favouritesAsync.maybeWhen(
            data: (list) => list.any(
              (f) => f.targetId == product.productId && f.targetType == 'item',
            ),
            orElse: () => false,
          );

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductDetailPageMobile(productId: productId),
                ),
              );
            },
            child: Stack(
              children: [
                Card(
                  elevation: 0,
                  color: AppColors.appBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                          bottom: Radius.circular(8),
                        ),
                        child: img == null
                            ? Container(
                                height: 130,
                                color: Colors.grey.shade200,
                                child: const Center(child: Text("No Image")),
                              )
                            : Image.network(
                                img,
                                height: 130,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.subtitle.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "MMK ${getFormattedPrice(product.price)}",
                                  style: AppFontStyle.subtitle.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  shopName ?? '',
                                  style: AppFontStyle.subtitle.copyWith(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Favourite icon
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        await ref
                            .read(favouriteNotifierProvider.notifier)
                            .toggleFavourite(
                              targetId: product.productId!,
                              targetType: 'item',
                            );

                        final isFav = ref
                            .read(favouriteNotifierProvider)
                            .maybeWhen(
                              data: (list) => list.any(
                                (f) =>
                                    f.targetId == product.productId! &&
                                    f.targetType == 'item',
                              ),
                              orElse: () => false,
                            );

                        showCustomToast(
                          // ignore: use_build_context_synchronously
                          context,
                          isFav
                              ? "Added to favorites"
                              : "Removed from favorites",
                          success: isFav,
                        );
                      } catch (e) {
                        showCustomToast(
                          // ignore: use_build_context_synchronously
                          context,
                          "Failed to update favorite",
                          success: false,
                        );
                      }
                    },
                    child: Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.45),
                      ),
                      child: Icon(
                        relatedProductIsFavourited
                            ? Icons.favorite
                            : Icons.favorite_outline,
                        color: relatedProductIsFavourited
                            ? Colors.red
                            : Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),

                // Stamp Label
                Positioned(
                  top: 20,
                  left: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(9),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 20,
                    ),
                    child: Text(
                      'Food Mandalay',
                      style: AppFontStyle.caption.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
