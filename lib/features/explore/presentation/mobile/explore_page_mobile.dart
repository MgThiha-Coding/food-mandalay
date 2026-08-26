import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/core/consts/app_images.dart';
import 'package:mandalar_x/features/category/data/category_list_notifier.dart';
import 'package:mandalar_x/features/category/model/category_list_model.dart';
import 'package:mandalar_x/features/home/data/product_list_notifier.dart';
import 'package:mandalar_x/features/product_detail/presentation/mobile/pages/product_detail_page_mobile.dart';

class ExplorePageMobile extends ConsumerStatefulWidget {
  const ExplorePageMobile({super.key});

  @override
  ConsumerState<ExplorePageMobile> createState() => _ExplorePageMobileState();
}

class _ExplorePageMobileState extends ConsumerState<ExplorePageMobile>
    with AutomaticKeepAliveClientMixin {
  final ScrollController scrollController = ScrollController();
  String selectedCategory = 'All'; // Default selection

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        ref.read(productListNotifierProvider.notifier).fetchProductList();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productNotifier = ref.read(productListNotifierProvider.notifier);
      final categoryNotifier = ref.read(categoryListNotifierProvider.notifier);

      if (ref
          .read(productListNotifierProvider)
          .maybeWhen(data: (list) => list.isEmpty, orElse: () => true)) {
        productNotifier.fetchProductList();
      }

      if (ref
          .read(categoryListNotifierProvider)
          .maybeWhen(data: (list) => list.isEmpty, orElse: () => true)) {
        categoryNotifier.fetchCategoryList();
      }
    });
  }

  Future<void> _refreshData() async {
    final productNotifier = ref.read(productListNotifierProvider.notifier);
    final categoryNotifier = ref.read(categoryListNotifierProvider.notifier);

    productNotifier.reset();
    await productNotifier.fetchProductList();
    await categoryNotifier.fetchCategoryList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final productListAsync = ref.watch(productListNotifierProvider);
    final categoryListAsync = ref.watch(categoryListNotifierProvider);

    // --------- Responsive helpers ----------
    final screenWidth = MediaQuery.of(context).size.width;
    const baseWidth = 375.0;
    final scale = (screenWidth / baseWidth).clamp(0.85, 1.15);

    //  final categoryWidth = (screenWidth * 0.22).clamp(85.0, 115.0);

    int crossAxisCount = 2;
    if (screenWidth >= 900) {
      crossAxisCount = 4;
    } else if (screenWidth >= 600)
      // ignore: curly_braces_in_flow_control_structures
      crossAxisCount = 3;
    else if (screenWidth >= 360)
      // ignore: curly_braces_in_flow_control_structures
      crossAxisCount = 2;

    // Fixed aspect ratio to prevent overflow (slightly taller)
    final childAspectRatio = 0.75;

    final categoryList = categoryListAsync.maybeWhen(
      data: (list) => [CategoryListModel('All', ''), ...list],
      orElse: () => [CategoryListModel('All', '')],
    );

    final filteredProducts = productListAsync.maybeWhen(
      data: (products) {
        if (selectedCategory == 'All') return products;
        return products
            .where((p) => (p.categoryName ?? '') == selectedCategory)
            .toList();
      },
      orElse: () => [],
    );

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        scrolledUnderElevation: 0,
        title: Text(
          'Explore',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primaryColor,
        child: Row(
          children: [
            Container(
              width: 70,
              color: AppColors.appBackground,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.0 * scale),
                itemCount: categoryList.length,
                itemBuilder: (context, index) {
                  final category = categoryList[index];
                  final isSelected = selectedCategory == category.categoryName;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category.categoryName ?? 'All';
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4.0 * scale),
                      padding: EdgeInsets.symmetric(vertical: 4.0 * scale),
                      color: isSelected
                          ? Colors.grey.shade200
                          : Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44 * scale.clamp(0.9, 1.1),
                            height: 44 * scale.clamp(0.9, 1.1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: category.categoryImage!.isEmpty
                                  ? Colors.grey[200]
                                  : Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: category.categoryImage!.isEmpty
                                  ? Icon(
                                      Icons.grid_view,
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : Colors.grey,
                                      size: 22 * scale.clamp(0.9, 1.1),
                                    )
                                  : Image.network(
                                      category.categoryImage!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 3 * scale),
                          // Fixed text overflow with FittedBox
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              category.categoryName ?? 'Unnamed',
                              style: TextStyle(
                                fontSize: 11 * scale.clamp(0.9, 1.05),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : Colors.black87,
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
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
              child: Container(
                color: Colors.grey.shade50,
                padding: EdgeInsets.all(6.0 * scale),
                child: filteredProducts.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 150 * scale),
                          Center(
                            child: Text(
                              'No products found',
                              style: TextStyle(
                                fontSize: 14 * scale.clamp(0.9, 1.1),
                              ),
                            ),
                          ),
                        ],
                      )
                    : GridView.builder(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 2 * scale,
                          crossAxisSpacing: 2 * scale,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          final img = product.productImage ?? '';
                          final productName = product.productName ?? '';
                          final productPrice = product.price ?? 0.0;
                          // final categoryName = product.categoryName ?? '';
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
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => ProductDetailPageMobile(
                                        productId: product.productId ?? '',
                                      ),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        const begin = Offset(
                                          1.0,
                                          0.0,
                                        ); // start from right
                                        const end = Offset
                                            .zero; // end at original position
                                        const curve = Curves
                                            .easeInOut; // smooth easing curve

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
                                // product item
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(10),
                                            ),
                                        child: img.isEmpty
                                            ? Image.asset(
                                                width: double.infinity,
                                                AppImages.emptyImage,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.network(
                                                img,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Container(
                                                      color:
                                                          Colors.grey.shade200,
                                                      child: Image.asset(
                                                        width: double.infinity,
                                                        AppImages.emptyImage,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                              ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: EdgeInsets.all(5.0 * scale),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 1 * scale,
                                              ),
                                              child: Text(
                                                productName,
                                                style: AppFontStyle.productName
                                                    .copyWith(
                                                      fontSize:
                                                          12 *
                                                          scale.clamp(
                                                            0.9,
                                                            1.05,
                                                          ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            // Price and category row
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (product.discount != null &&
                                                    product.discount > 0)
                                                  Text(
                                                    originalPriceText,
                                                    style: const TextStyle(
                                                      decoration: TextDecoration
                                                          .lineThrough,
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
                                      ),
                                    ),
                                  ],
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
                                      horizontal: 10,
                                    ),
                                    child: Text(
                                      product.discount != null &&
                                              product.discount > 0
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
            /*
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
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
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
                                  width: 120,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                    child: image == null
                                        ? Image.asset(AppImages.emptyImage)
                                        : Image.network(
                                            image,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
            */
          ],
        ),
      ),
    );
  }
}
