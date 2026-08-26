import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart' show ToastGravity, FToast;
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/favourites/data/favourite_notifier.dart';
import 'package:mandalar_x/features/product_detail/presentation/mobile/pages/product_detail_page_mobile.dart';

class RelatedFoodSection extends ConsumerStatefulWidget {
  final List relatedFoodList;
  final String productId;
  const RelatedFoodSection({
    super.key,
    required this.relatedFoodList,
    required this.productId,
  });

  @override
  ConsumerState<RelatedFoodSection> createState() => _RelatedFoodSectionState();
}

class _RelatedFoodSectionState extends ConsumerState<RelatedFoodSection> {
  @override
  Widget build(BuildContext context) {
    final favouritesAsync = ref.watch(favouriteNotifierProvider);

    String getFormattedPrice(double? price) {
      if (price == null) return '';
      return price.truncateToDouble() == price
          ? price.toInt().toString()
          : price.toString();
    }

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
          borderRadius: BorderRadius.circular(6),
          color: success ? Colors.black87 : Colors.red,
        ),
        child: Text(
          message,
          style: AppFontStyle.body.copyWith(
            fontFamily: 'Poppins',
            fontSize: 14,
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

    return widget.relatedFoodList.isNotEmpty
        ? ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.relatedFoodList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = widget.relatedFoodList[index];
              final img = product.productImage;

              final relatedProductIsFavourited = favouritesAsync.maybeWhen(
                data: (list) => list.any(
                  (f) =>
                      f.targetId == product.productId &&
                      f.targetType == 'item',
                ),
                orElse: () => false,
              );

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPageMobile(
                        productId: product.productId,
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12),
                                  bottom: Radius.circular(12),
                                ),
                                child: img == null
                                    ? Container(
                                        height: 120,
                                        color: Colors.grey.shade200,
                                        child: Center(
                                          child: Text("No Image"),
                                        ),
                                      )
                                    : Image.network(
                                        img,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ],
                          ),
                        ),

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
                                            f.targetId ==
                                                product.productId! &&
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

                        Positioned(
                          top: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(4),
                                bottomRight: Radius.circular(9),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 20,
                            ),
                            child: Text(
                              'Food Mandalay',
                              style: AppFontStyle.caption.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),

                          Text(
                            "MMK ${getFormattedPrice(product.price)}",
                            style: AppFontStyle.subtitle.copyWith(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        : SizedBox.shrink();
  }
}

