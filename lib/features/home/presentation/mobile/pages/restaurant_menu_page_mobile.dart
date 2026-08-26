import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/core/consts/app_images.dart';
import 'package:mandalar_x/features/category/data/category_list_notifier.dart';
import 'package:mandalar_x/features/category/model/category_list_model.dart';
import 'package:mandalar_x/features/home/data/product_list_notifier.dart';
import 'package:mandalar_x/features/home/data/restaurant_list_notifier.dart';
import 'package:mandalar_x/features/product_detail/presentation/mobile/pages/product_detail_page_mobile.dart';
import 'package:mandalar_x/shared/mandalarx_loading.dart';

class RestaurantMenuPageMobile extends ConsumerStatefulWidget {
  final String merchantId;

  const RestaurantMenuPageMobile({super.key, required this.merchantId});

  @override
  ConsumerState<RestaurantMenuPageMobile> createState() =>
      _RestaurantMenuPageMobileState();
}

class _RestaurantMenuPageMobileState
    extends ConsumerState<RestaurantMenuPageMobile>
    with AutomaticKeepAliveClientMixin {
  final ScrollController scrollController = ScrollController();
  String selectedCategory = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        ref
            .read(
              merchantProductListNotifierProvider(widget.merchantId).notifier,
            )
            .reset();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryListNotifierProvider.notifier).fetchCategoryList();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final productAsync = ref.watch(
      merchantProductListNotifierProvider(widget.merchantId),
    );
    final categoryAsync = ref.watch(categoryListNotifierProvider);
    final restaurantAsync = ref.watch(restaurantListNotifierProvider);

    if (restaurantAsync.isLoading) {
      return const Scaffold(body: Center(child: MandalarXTextLoading()));
    }

    final restaurant = restaurantAsync.maybeWhen(
      data: (list) {
        try {
          return list.firstWhere((r) => r.ownerId == widget.merchantId);
        } catch (_) {
          return null;
        }
      },
      orElse: () => null,
    );

    if (restaurant == null) {
      return const Scaffold(body: Center(child: Text('Restaurant not found')));
    }

    final categoryList = categoryAsync.maybeWhen(
      data: (list) => [CategoryListModel('All', ''), ...list],
      orElse: () => [CategoryListModel('All', '')],
    );

    final filteredProducts = productAsync.maybeWhen(
      data: (list) {
        if (selectedCategory.isEmpty) return list;
        return list.where((p) => p.categoryName == selectedCategory).toList();
      },
      orElse: () => [],
    );

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Column(
        children: [
          // Top Profile + Buttons
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(color: AppColors.appBackground),
              ),
              Positioned(
                top: 40,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleButton(
                      icon: Icons.arrow_back_ios,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 70,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: restaurant.image != null
                          ? NetworkImage(restaurant.image!)
                          : null,
                      child: restaurant.image == null
                          ? Icon(Icons.store, size: 32, color: Colors.grey)
                          : null,
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          Text(
                            restaurant.name ?? 'Restaurant',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                            ),
                          ),
                          Text(
                            restaurant.description ?? 'Restaurant',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppFontStyle.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Category List
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: categoryList.length,
              itemBuilder: (context, index) {
                final category = categoryList[index];
                final name = category.categoryName ?? "Unnamed";
                final image = category.categoryImage ?? "";
                final isSelected =
                    selectedCategory == category.categoryName ||
                    (selectedCategory.isEmpty && name == 'All');

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = (name == 'All') ? '' : name;
                    });
                  },
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: image.isEmpty
                                ? Colors.grey[100]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: image.isEmpty
                                ? Icon(
                                    Icons.grid_view,
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : Colors.grey,
                                  )
                                : Image.network(image, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  final image = product.productImage ?? '';
                  final productName = product.productName ?? '';
                  final productPrice = product.price ?? 0.0;

                  double calculateDiscountPrice(
                    double price,
                    double? discount,
                  ) {
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
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  ProductDetailPageMobile(
                                    productId: product.productId ?? '',
                                  ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;

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
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 120,
                                width: 140,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  child: image == null
                                      ? Image.asset(AppImages.emptyImage)
                                      : Image.network(image, fit: BoxFit.cover),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      productName,
                                      style: AppFontStyle.label,
                                    ),
                                    if (product.discount != null &&
                                        product.discount > 0)
                                      Text(
                                        originalPriceText,
                                        style: const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
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
                              ),
                            ],
                          ),
                        ),

                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              shape: CircleBorder(),
                            ),
                            onPressed: () {},
                            icon: Icon(Icons.add),
                          ),
                        ),

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
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.45),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
