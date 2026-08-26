import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/cart/data/cart_notifier.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/features/cart/presentation/mobile/widget/cart_icon.dart';
import 'package:mandalar_x/features/cart/presentation/mobile/widget/cart_list_section.dart';
import 'package:mandalar_x/features/cart/presentation/mobile/widget/check_out_button.dart';
import 'package:mandalar_x/shared/mandalarx_loading.dart';

class CartPageMobile extends ConsumerStatefulWidget {
  const CartPageMobile({super.key});

  @override
  ConsumerState<CartPageMobile> createState() => _CartPageMobileState();
}

class _CartPageMobileState extends ConsumerState<CartPageMobile>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool showButton = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryNotifier = ref.read(cartNotifierProvider.notifier);
      if (ref
          .read(cartNotifierProvider)
          .maybeWhen(data: (list) => list.isEmpty, orElse: () => true)) {
        categoryNotifier.fetchCartItems();
      }
    });
  }

  String getFormattedPrice(double? price) {
    if (price == null) return '';
    return price.truncateToDouble() == price
        ? price.toInt().toString()
        : price.toString();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cartState = ref.watch(cartNotifierProvider);

    final totalPrice = cartState.when(
      data: (data) {
        if (data.isEmpty) {
          showButton = false;
        }

        return data.fold<double>(
          0.0,
          (sum, e) => sum + (e.finalPrice * e.itemCount),
        );
      },
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );

    final totalItemCount = cartState.when(
      data: (data) {
        if (data.isEmpty) return 0;

        return data.fold<int>(0, (sum, e) => sum + e.itemCount);
      },
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'My Cart',
          style: AppFontStyle.title.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        actions: [CartIcon(totalItemCount: totalItemCount)],
      ),

      body: RefreshIndicator(
        color: Colors.red,
        backgroundColor: Colors.white,
        onRefresh: () async {
          ref.read(cartNotifierProvider.notifier).fetchCartItems();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: cartState.when(
            data: (cartList) {
              if (cartList.isEmpty) {
                return Center(
                  child: Text(
                    "Your cart is empty",
                    style: AppFontStyle.body.copyWith(color: Colors.grey),
                  ),
                );
              }

              return CartListSection(cartList: cartList);
            },
            loading: () =>
                Center(child: SpinKitFadingCircle(color: Colors.red)),
            error: (error, _) => Center(child: MandalarXTextLoading()),
          ),
        ),
      ),

      bottomNavigationBar: showButton
          ? CheckOutButton(totalPrice: totalPrice)
          : SizedBox.shrink(),
    );
  }
}
