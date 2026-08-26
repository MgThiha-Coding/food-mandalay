import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/core/consts/app_images.dart';
import 'package:mandalar_x/features/cart/data/cart_notifier.dart';
import 'package:mandalar_x/features/favourites/data/favourite_notifier.dart';
import 'package:mandalar_x/features/home/data/product_list_notifier.dart';
import 'package:mandalar_x/features/product_detail/data/product_detail_notifier.dart';
import 'package:mandalar_x/features/product_detail/presentation/mobile/widgets/related_food_section.dart';
import 'package:mandalar_x/features/product_detail/presentation/mobile/widgets/review_list_section.dart';
import 'package:mandalar_x/features/review/data/product_review_notifier.dart';
import 'package:mandalar_x/features/review/presentation/mobile/review_page_mobile.dart';
import 'package:mandalar_x/shared/app_button.dart';

class ProductDetailPageMobile extends ConsumerStatefulWidget {
  final String? productId;

  const ProductDetailPageMobile({super.key, this.productId});

  @override
  ConsumerState<ProductDetailPageMobile> createState() =>
      _ProductDetailPageMobileState();
}

class _ProductDetailPageMobileState
    extends ConsumerState<ProductDetailPageMobile>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  int count = 1;
  String? selectedSpicyLevel;
  final TextEditingController reviewController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productListNotifierProvider.notifier).fetchProductList(page: 0);
      ref
          .read(productReviewNotifierProvider.notifier)
          .fetchReviews(int.parse(widget.productId!));

      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      )..repeat();

      _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    });
  }

  @override
  void dispose() {
    reviewController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void increment() {
    setState(() => count++);
  }

  void decrement() {
    if (count > 1) setState(() => count--);
  }

  String getFormattedPrice(double? price) {
    if (price == null) return '';
    return price.truncateToDouble() == price
        ? price.toInt().toString()
        : price.toString();
  }

  bool isShopOpen(DateTime? open, DateTime? close) {
    if (open == null || close == null) return true;

    final now = DateTime.now();

    final openTime = DateTime(
      now.year,
      now.month,
      now.day,
      open.hour,
      open.minute,
    );
    var closeTime = DateTime(
      now.year,
      now.month,
      now.day,
      close.hour,
      close.minute,
    );

    if (closeTime.isBefore(openTime)) {
      closeTime = closeTime.add(Duration(days: 1));
    }

    return now.isAfter(openTime) && now.isBefore(closeTime);
  }

  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} mins ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} week(s) ago';
    }
    return '${(difference.inDays / 30).floor()} month(s) ago';
  }

  Widget _buildAnimatedDots(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        int activeDot = (_animation.value * 3).floor();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < 3; i++)
              AnimatedOpacity(
                opacity: i <= activeDot ? 1 : 0.2,
                duration: const Duration(milliseconds: 250),
                child: Text('.', style: AppFontStyle.title),
              ),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId!));
    final productListAsync = ref.watch(productListNotifierProvider);
    final productList = productListAsync.value ?? [];
    ref.watch(favouriteNotifierProvider);

    return productAsync.when(
      data: (product) {
        if (product == null) {
          return Scaffold(body: Center(child: Text("Product not found")));
        }

        final relatedFoodList = productList.where((e) {
          return e.categoryName == product.categoryName &&
              e.productId != product.productId;
        }).toList();

        final imageURL = product.productImage;
        final isAvailable = isShopOpen(
          product.shopOpenTime?.toLocal(),
          product.shopCloseTime?.toLocal(),
        );

        final reviewsAsync = ref.watch(productReviewNotifierProvider);

        final favouritesAsync = ref.watch(favouriteNotifierProvider);

        final bool isFavourited = favouritesAsync.maybeWhen(
          data: (list) => list.any(
            (f) => f.targetId == product.productId && f.targetType == 'item',
          ),
          orElse: () => false,
        );

        return Scaffold(
          backgroundColor: AppColors.appPrimaryColor,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // product Image
                    AspectRatio(
                      aspectRatio: 1.7,
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        child: imageURL == null
                            ? Image.asset(
                                AppImages.emptyImage,
                                fit: BoxFit.cover,
                              )
                            : Image.network(imageURL, fit: BoxFit.cover),
                      ),
                    ),

                    // product description
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isAvailable
                                    ? "Available Now"
                                    : "Currently unavailable",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isAvailable
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),

                              Text(
                                product.supplierName ?? "",
                                style: AppFontStyle.productName.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            product.productName ?? "",
                            style: AppFontStyle.label.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Stock ${product.stock.toString()}",
                            style: AppFontStyle.label.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),

                          SizedBox(height: 2),

                          Text(
                            "MMK ${getFormattedPrice(product.price)}",
                            style: AppFontStyle.body.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 14),

                          if (product.description?.isNotEmpty == true)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                product.description ?? "No Description",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 13,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),

                          /*
                          if (product.isSpicyLevelEnabled == true) ...[
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Spicy Level',
                                    style: AppFontStyle.subtitle,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Mild',
                                            style: AppFontStyle.caption,
                                          ),
                                          Checkbox(
                                            value: selectedSpicyLevel == 'Mild',
                                            shape: CircleBorder(),
                                            activeColor: Colors.red,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedSpicyLevel =
                                                    value == true
                                                    ? 'Mild'
                                                    : null;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Row(
                                        children: [
                                          Text(
                                            'Medium',
                                            style: AppFontStyle.caption,
                                          ),
                                          Checkbox(
                                            value:
                                                selectedSpicyLevel == 'Medium',
                                            shape: CircleBorder(),
                                            activeColor: Colors.red,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedSpicyLevel =
                                                    value == true
                                                    ? 'Medium'
                                                    : null;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Row(
                                        children: [
                                          Text(
                                            'Hot',
                                            style: AppFontStyle.caption,
                                          ),
                                          Checkbox(
                                            value: selectedSpicyLevel == 'Hot',
                                            shape: CircleBorder(),
                                            activeColor: Colors.red,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedSpicyLevel =
                                                    value == true
                                                    ? 'Hot'
                                                    : null;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                          */
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Customer Reviews',
                                style: AppFontStyle.subtitle.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReviewPageMobile(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'See all',
                                  style: AppFontStyle.subtitle.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Divider(),

                          reviewsAsync.when(
                            data: (data) {
                              if (data.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 3,
                                  ),
                                  child: SizedBox.shrink(),
                                );
                              }

                              return ReviewListSection(reviewList: data);
                            },
                            loading: () => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: _buildAnimatedDots(Colors.red),
                              ),
                            ),
                            error: (error, st) => SizedBox.shrink(),
                          ),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReviewPageMobile(
                                    productId: product.productId!,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 37,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.message_outlined,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Leave a review',
                                    style: AppFontStyle.caption.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          RelatedFoodSection(
                            relatedFoodList: relatedFoodList,
                            productId: product.productId!,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 15,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.45),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
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
                            isFavourited
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color: isFavourited ? Colors.red : Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 5,
                color: AppColors.appBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                  height: 60,
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 38,
                        width: 38,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            // ignore: deprecated_member_use
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            shape: CircleBorder(),
                          ),
                          onPressed: decrement,
                          icon: Icon(Icons.remove, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(count.toString(), style: AppFontStyle.body),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 38,
                        width: 38,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            // ignore: deprecated_member_use
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            shape: CircleBorder(),
                          ),
                          onPressed: increment,
                          icon: Icon(Icons.add, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          title: "Add to cart",
                          backgroundColor: isAvailable
                              ? Colors.red
                              : Colors.grey.shade400,
                          labelColor: Colors.white,
                          isLoading: ref.watch(cartNotifierProvider).isLoading,
                          onTap: () async {
                            if (!isAvailable && product.stock == 0) return;
                            final success = await ref
                                .read(cartNotifierProvider.notifier)
                                .addToCart(
                                  productId: widget.productId!,
                                  itemCount: count,
                                  selectedSpicyLevel: selectedSpicyLevel,
                                );

                            showCustomToast(
                              // ignore: use_build_context_synchronously
                              context,
                              success
                                  ? "Item added to cart"
                                  : "Failed to add item",
                              success: success,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.appBackground,
        body: Center(child: SpinKitFadingCircle(color: Colors.red, size: 50)),
      ),

      error: (err, st) =>
          Scaffold(body: Center(child: Text('Failed to load product'))),
    );
  }
}
