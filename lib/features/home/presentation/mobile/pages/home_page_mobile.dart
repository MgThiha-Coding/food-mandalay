import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/category/data/category_list_notifier.dart';
import 'package:mandalar_x/features/category/model/category_list_model.dart';
import 'package:mandalar_x/features/home/data/product_list_notifier.dart';
import 'package:mandalar_x/features/home/data/restaurant_list_notifier.dart';
import 'package:mandalar_x/features/home/presentation/mobile/widgets/app_bar_search.dart';
import 'package:mandalar_x/features/home/presentation/mobile/widgets/carousel_section.dart';
import 'package:mandalar_x/features/home/presentation/mobile/widgets/restaurant_list_section.dart';
import 'package:mandalar_x/features/search/presentation/mobile/search_page_mobile.dart';
import 'package:mandalar_x/shared/animated_search_hint.dart';
import 'package:mandalar_x/shared/mandalarx_loading.dart';

class HomePageMobile extends ConsumerStatefulWidget {
  const HomePageMobile({super.key});

  @override
  ConsumerState<HomePageMobile> createState() => _HomePageMobileState();
}

class _HomePageMobileState extends ConsumerState<HomePageMobile>
    with AutomaticKeepAliveClientMixin {
  final ScrollController scrollController = ScrollController();
  String selectedCategory = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Infinite scroll for products
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        ref.read(productListNotifierProvider.notifier).fetchProductList();
      }
    });

    // Fetch initial data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productNotifier = ref.read(productListNotifierProvider.notifier);
      final categoryNotifier = ref.read(categoryListNotifierProvider.notifier);
      final restaurantNotifier = ref.read(
        restaurantListNotifierProvider.notifier,
      );

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

      if (ref
          .read(restaurantListNotifierProvider)
          .maybeWhen(data: (list) => list.isEmpty, orElse: () => true)) {
        restaurantNotifier.fetchRestaurants();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    ref.read(productListNotifierProvider.notifier).reset();
    await ref.read(productListNotifierProvider.notifier).fetchProductList();
    await ref.read(categoryListNotifierProvider.notifier).fetchCategoryList();
    await ref.read(restaurantListNotifierProvider.notifier).fetchRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final productListAsync = ref.watch(productListNotifierProvider);
    final categoryListAsync = ref.watch(categoryListNotifierProvider);
    final restaurantListAsync = ref.watch(restaurantListNotifierProvider);

    final screenHeight = MediaQuery.of(context).size.height;

    final categoryList = categoryListAsync.maybeWhen(
      data: (list) => [CategoryListModel('All', ''), ...list],
      orElse: () => [CategoryListModel('All', '')],
    );

    if (categoryListAsync.isLoading &&
        productListAsync.isLoading &&
        restaurantListAsync.isLoading) {
      return const Center(child: MandalarXTextLoading());
    }

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: const AppBarSearch(),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        backgroundColor: AppColors.appBackground,
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          key: const PageStorageKey('home_scroll_view'),
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: GestureDetector(
                  onTap: () {
                    final hint = ref.watch(randomSearchHintProvider);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchPageMobile(initialQuery: hint),
                      ),
                    );
                  },
                  child: TextField(
                    enabled: false, // disables keyboard/focus
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    decoration: InputDecoration(
                      hint: Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedRandomSearchHint(),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        LineIcons.search,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              CarouselSection(screenHeight: screenHeight),

              // Category List Section
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
                          horizontal: 3,
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

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Restaurants', style: AppFontStyle.label),
              ),
              
              restaurantListAsync.when(
                data: (restaurants) {
                  // Filter restaurants by products in selected category
                  final filteredRestaurants = restaurants.where((restaurant) {
                    if (selectedCategory.isEmpty) return true;

                    final restaurantProducts = ref
                        .read(productListNotifierProvider)
                        .maybeWhen(data: (list) => list, orElse: () => []);

                    return restaurantProducts.any(
                      (product) =>
                          product.ownerId == restaurant.ownerId &&
                          product.categoryName == selectedCategory,
                    );
                  }).toList();

                  if (filteredRestaurants.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text('No Restaurants Available')),
                    );
                  }

                  return RestaurantListSection(
                    restaurants: filteredRestaurants,
                  );
                },
                loading: () => const Center(child: MandalarXTextLoading()),
                error: (_, __) => Center(
                  child: TextButton(
                    onPressed: () {
                      ref.read(restaurantListNotifierProvider.notifier)
                          .reset();
                      ref.read(restaurantListNotifierProvider.notifier)
                          .fetchRestaurants();
                    },
                    child: const Text('Unable to load restaurants. Retry'),
                  ),
                ),
              ),

              // Bottom Spacing
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
