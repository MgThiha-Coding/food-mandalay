import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/core/consts/app_images.dart';
import 'package:mandalar_x/features/cart/data/cart_notifier.dart';
import 'package:mandalar_x/features/cart/model/cart_product_model.dart';

class CartListSection extends ConsumerWidget {
  final List cartList;
  const CartListSection({super.key, required this.cartList});

  String getFormattedPrice(double? price) {
    if (price == null) return '';
    return price.truncateToDouble() == price
        ? price.toInt().toString()
        : price.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: cartList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final CartProductModel item = cartList[index];
        final imageUrl = item.productImage;
        final subtotal = (item.price ?? 0) * item.itemCount;

        Future<void> showAlertDialog(String productId) async {
          return showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text('Remove Item', style: AppFontStyle.title),
              content: Text(
                'Are you sure you want to remove this item from the cart?',
                style: AppFontStyle.caption.copyWith(color: Colors.red),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: AppFontStyle.caption.copyWith(color: Colors.green),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref
                        .read(cartNotifierProvider.notifier)
                        .removeFromCart(productId);

                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Delete',
                    style: AppFontStyle.caption.copyWith(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),

                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (imageUrl != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                      child: Image.network(
                        imageUrl,
                        height: 120,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      height: 120,
                      width: 90,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Image.asset(
                        AppImages.emptyImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          item.productName ?? "Unknown",
                          style: AppFontStyle.label.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "MMK",
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 13,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                Text('Subtotal', style: AppFontStyle.caption),

                                const SizedBox(height: 4),
                              ],
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getFormattedPrice(item.price),
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 13,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                Text(
                                  getFormattedPrice(subtotal),
                                  style: AppFontStyle.caption,
                                ),

                                const SizedBox(height: 4),
                              ],
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox.shrink(),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    ref
                                        .read(cartNotifierProvider.notifier)
                                        .decrementItem(item.productId);
                                  },
                                  icon: Icon(Icons.remove),
                                ),
                                Text(
                                  "${item.itemCount}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    ref
                                        .read(cartNotifierProvider.notifier)
                                        .incrementItem(item.productId);
                                  },
                                  icon: Icon(Icons.add),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () {
                  showAlertDialog(item.productId);
                },
                icon: Icon(Icons.delete, size: 20),
              ),
            ),
          ],
        );
      },
    );
  }
}
