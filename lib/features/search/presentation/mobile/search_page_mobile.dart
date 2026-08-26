import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/product_detail/presentation/mobile/pages/product_detail_page_mobile.dart';
import 'package:mandalar_x/features/search/data/product_search_notifier.dart';

class SearchPageMobile extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchPageMobile({super.key, this.initialQuery});

  @override
  ConsumerState<SearchPageMobile> createState() => _SearchPageMobileState();
}

class _SearchPageMobileState extends ConsumerState<SearchPageMobile> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialQuery ?? '');

    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      Future.microtask(() {
        ref
            .read(productSearchNotifierProvider.notifier)
            .search(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(productSearchNotifierProvider);
    final searchNotifier = ref.read(productSearchNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.appBackground,
        title: SearchField(controller: _controller),
      ),
      body: searchAsync.when(
        loading: () => const _DotLoading(),
        error: (_, __) => const _DotLoading(),
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Text(
                searchNotifier.lastQuery.isEmpty
                    ? 'Search food, shops, categories'
                    : 'No result found',
                style: AppFontStyle.caption.copyWith(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(4),
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = products[index];
              final image = product.productImage ?? "";

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailPageMobile(productId: product.productId),
                    ),
                  );
                },
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: image.isEmpty
                      ? Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade200,
                        )
                      : Image.network(
                          image,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey.shade200,
                          ),
                        ),
                ),
                title: Text(
                  product.productName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.caption.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                subtitle: Text(
                  product.supplierName ?? product.categoryName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.caption.copyWith(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                trailing: Text(
                  product.categoryName ?? "",
                  style: AppFontStyle.caption.copyWith(color: Colors.blue),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SearchField extends ConsumerStatefulWidget {
  final TextEditingController controller;

  const SearchField({super.key, required this.controller});

  @override
  ConsumerState<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<SearchField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: widget.controller,
        autofocus: true,
        onChanged: (value) {
          // search as user types (debounced in notifier)
          ref.read(productSearchNotifierProvider.notifier).search(value);
        },
        style: AppFontStyle.caption,
        decoration: InputDecoration(
          hintText: 'Search food, shop, category',
          hintStyle: AppFontStyle.caption.copyWith(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, size: 22, color: Colors.grey),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Clear',
                onPressed: () {
                  widget.controller.clear();
                  ref.read(productSearchNotifierProvider.notifier).search('');
                },
                icon: const Icon(Icons.cancel, size: 22, color: Colors.grey),
              ),

              IconButton(
                tooltip: 'Refresh',
                onPressed: () {
                  ref.read(productSearchNotifierProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh, size: 22, color: Colors.grey),
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

class _DotLoading extends StatefulWidget {
  const _DotLoading();

  @override
  State<_DotLoading> createState() => _DotLoadingState();
}

class _DotLoadingState extends State<_DotLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  int dotCount = 1;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();

    _opacity = Tween<double>(
      begin: 0.35,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addListener(() {
      if (_controller.value > 0.95) {
        setState(() {
          dotCount = dotCount == 3 ? 1 : dotCount + 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (_, __) {
          return Opacity(
            opacity: _opacity.value,
            child: Text(
              '.' * dotCount,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 4,
              ),
            ),
          );
        },
      ),
    );
  }
}
