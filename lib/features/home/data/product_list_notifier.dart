import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/features/home/model/product_list_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class ProductListNotifier
    extends StateNotifier<AsyncValue<List<ProductListModel>>> {
  ProductListNotifier() : super(const AsyncValue.data([])) {
    fetchProductList();
  }

  static const int _pageSize = 8;

  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;

  /// Fetch all products with pagination
  Future<void> fetchProductList({int page = 0, int pageSize = 20}) async {
    if (_isLoading || !_hasMore) return;

    try {
      _isLoading = true;

      if (_currentPage == 0) {
        state = const AsyncValue.loading();
      }

      final start = _currentPage * _pageSize;
      final end = start + _pageSize - 1;

      final response = await Supabase.instance.client
          .from('items')
          .select()
          .order('created_at', ascending: false)
          .range(start, end)
          .timeout(const Duration(seconds: 10));

      final newItems = (response as List)
          .map((e) => ProductListModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (newItems.length < _pageSize) {
        _hasMore = false;
      }

      final currentItems = state.value ?? [];
      state = AsyncValue.data([...currentItems, ...newItems]);

      _currentPage++;
    } on SocketException catch (e, st) {
      state = AsyncValue.error(e, st);
    } on TimeoutException catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isLoading = false;
    }
  }

  void reset() {
    _currentPage = 0;
    _hasMore = true;
    state = const AsyncValue.data([]);
  }
}

final productListNotifierProvider =
    StateNotifierProvider<ProductListNotifier, AsyncValue<List<ProductListModel>>>(
        (ref) => ProductListNotifier());



class MerchantProductListNotifier
    extends StateNotifier<AsyncValue<List<ProductListModel>>> {
  MerchantProductListNotifier(this.merchantId)
      : super(const AsyncValue.loading()) {
    fetchOnce();
  }

  final String merchantId;

  Future<void> fetchOnce() async {
    try {
      state = const AsyncValue.loading();

      final response = await Supabase.instance.client
          .from('items')
          .select()
          .eq('owner_id', merchantId)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 10));

      final items = (response as List)
          .map((e) => ProductListModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(items);
    } on SocketException catch (e, st) {
      state = AsyncValue.error(e, st);
    } on TimeoutException catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.loading();
    fetchOnce();
  }
}

final merchantProductListNotifierProvider = StateNotifierProvider.family<
    MerchantProductListNotifier,
    AsyncValue<List<ProductListModel>>,
    String>(
  (ref, merchantId) => MerchantProductListNotifier(merchantId),
);
