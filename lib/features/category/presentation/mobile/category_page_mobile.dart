import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/category/data/category_list_notifier.dart';
import 'package:mandalar_x/features/home/data/product_list_notifier.dart';
import 'package:mandalar_x/features/product_detail/presentation/mobile/pages/product_detail_page_mobile.dart';
import 'package:mandalar_x/shared/mandalarx_loading.dart';

class CategoryPageMobile extends ConsumerStatefulWidget {
  const CategoryPageMobile({super.key});

  @override
  ConsumerState<CategoryPageMobile> createState() => _CategoryPageMobileState();
}

class _CategoryPageMobileState extends ConsumerState<CategoryPageMobile>
    with AutomaticKeepAliveClientMixin {
  String selectedCategory = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productNotifier = ref.read(productListNotifierProvider.notifier);
      if (ref
          .read(productListNotifierProvider)
          .maybeWhen(data: (list) => list.isEmpty, orElse: () => true)) {
        productNotifier.fetchProductList(page: 0);
      }

      final categoryNotifier = ref.read(categoryListNotifierProvider.notifier);
      if (ref
          .read(categoryListNotifierProvider)
          .maybeWhen(data: (list) => list.isEmpty, orElse: () => true)) {
        categoryNotifier.fetchCategoryList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final categoryAsync = ref.watch(categoryListNotifierProvider);
    final productAsync = ref.watch(productListNotifierProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      /*
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Explore',
          style: AppFontStyle.title.copyWith(color: Colors.black, fontSize: 15),
        ),
      ),
      */
      body: categoryAsync.when(
        loading: () => const MandalarXTextLoading(),
        error: (_, __) => const MandalarXTextLoading(),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: MandalarXTextLoading());
          }

          final products = productAsync.value ?? [];
          final filteredProducts = selectedCategory.isEmpty
              ? products
              : products
                    .where((e) => e.categoryName == selectedCategory)
                    .toList();

          return Stack(
            children: [
              // Product Grid
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 32),
                  child: productAsync.when(
                    loading: () => const MandalarXTextLoading(),
                    error: (_, __) => const MandalarXTextLoading(),
                    data: (_) {
                      if (filteredProducts.isEmpty) {
                        return Center(
                          child: Text(
                            'No dishes available',
                            style: AppFontStyle.caption,
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.22),
                        itemCount: filteredProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                              childAspectRatio: 0.75,
                            ),
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          final image = product.productImage ?? "";

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
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: image.isEmpty
                                          ? const SizedBox()
                                          : Image.network(
                                              image,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const SizedBox(),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      product.productName ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: AppFontStyle.caption.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // Bottom horizontal category list (close to bottom)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: screenHeight * 0.12,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final name = categories[index].categoryName ?? '';
                      final isSelected = name == selectedCategory;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = name;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 33,
                                backgroundColor: isSelected
                                    ? Colors.red
                                    : Colors.grey.shade200,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    name,
                                    textAlign: TextAlign.center,
                                    style: AppFontStyle.caption.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
