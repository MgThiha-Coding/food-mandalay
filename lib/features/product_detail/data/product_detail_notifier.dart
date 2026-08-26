import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/features/home/model/product_list_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetailNotifier
    extends StateNotifier<AsyncValue<ProductListModel?>> {
  final String productId;

  ProductDetailNotifier({required this.productId})
    : super(const AsyncValue.loading()) {
    fetchProductDetail();
  }

  Future<void> fetchProductDetail() async {
    try {
      state = const AsyncValue.loading();

      final response = await Supabase.instance.client
          .from('items')
          .select()
          .eq('product_id', productId)
          .single()
          .timeout(const Duration(seconds: 10));

      final product = ProductListModel.fromJson(response);
      state = AsyncValue.data(product);
    } on TimeoutException catch (_) {
      state = AsyncValue.error('Request timed out', StackTrace.current);
    } catch (error, st) {
      state = AsyncValue.error(error, st);
    }
  }
}

/// Riverpod provider for product detail by ID
final productDetailProvider =
    StateNotifierProvider.family<
      ProductDetailNotifier,
      AsyncValue<ProductListModel?>,
      String
    >((ref, productId) {
      return ProductDetailNotifier(productId: productId);
    });
