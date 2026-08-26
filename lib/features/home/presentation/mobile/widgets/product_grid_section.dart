import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/core/consts/app_images.dart';
import 'package:mandalar_x/features/product_detail/presentation/mobile/pages/product_detail_page_mobile.dart';

class ProductGridSection extends ConsumerWidget {
  final List products;

  const ProductGridSection({super.key, required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text('No Products', style: AppFontStyle.subtitle)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
          childAspectRatio: 0.70,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          return _ProductCard(product: product);
        },
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final dynamic product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final img = product.productImage ?? '';
    final productName = product.productName ?? '';
    final supplierName = product.supplierName ?? '';
    final productPrice = product.price ?? 0.0;

    double calculateDiscountPrice(double price, double? discount) {
      if (discount == null || discount <= 0) return price;
      return price - (price * (discount / 100));
    }

    final discountedPrice = calculateDiscountPrice(
      productPrice,
      product.discount,
    );

    // Price and Category
    final originalPriceText =
        'Ks${productPrice % 1 == 0 ? productPrice.toInt() : productPrice}';
    final discountedPriceText =
        'Ks${discountedPrice % 1 == 0 ? discountedPrice.toInt() : discountedPrice}';

    // Check if either price is too long (5+ digits)
    /* final useColumn =
        originalPriceText.length > 5 || discountedPriceText.length > 5;
        */

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProductDetailPageMobile(productId: product.productId ?? ''),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0); // start from right
                  const end = Offset.zero; // end at original position
                  const curve = Curves.easeInOut; // smooth easing curve

                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
          ),
        );
      },
      child: Stack(
        children: [
          Card(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                color: AppColors.appBackground,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                            bottom: Radius.circular(8),
                          ),
                          child: img.isEmpty
                              ? Image.asset(
                                  width: double.infinity,
                                  height: 130,
                                  AppImages.emptyImage,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  img,
                                  height: 130,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade200,
                                    child: Image.asset(
                                      width: double.infinity,
                                      height: 130,
                                      AppImages.emptyImage,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                        ),

                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            // ignore: deprecated_member_use
                            color: Colors.black87.withOpacity(0.6),
                            padding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Text(
                              supplierName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: AppFontStyle.caption.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 32,
                                child: Text(
                                  productName,
                                  style: AppFontStyle.productName.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              const Spacer(),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (product.discount != null &&
                                      product.discount > 0)
                                    Text(
                                      originalPriceText,
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  Text(
                                    discountedPriceText,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /*
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: () async{
                await ref.read(cartNotifierProvider.notifier).addToCart(productId: product.productId?? "");
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                ),
                child: const Icon(Icons.add, color: Colors.red, size: 18),
              ),
            ),
          ),
          */

          // Top-left label
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              child: Text(
                product.discount != null && product.discount > 0
                    ? '${product.discount.toStringAsFixed(0)}% OFF'
                    : '0% OFF', // show 0% if discount is 0
                style: AppFontStyle.caption.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
