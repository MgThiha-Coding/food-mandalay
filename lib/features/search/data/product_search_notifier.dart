import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/features/home/model/product_list_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductSearchNotifier
    extends StateNotifier<AsyncValue<List<ProductListModel>>> {
  ProductSearchNotifier() : super(const AsyncValue.data([]));

  Timer? _debounce;
  String lastQuery = '';

  void search(String query) {
    _debounce?.cancel();
    lastQuery = query.trim();

    if (lastQuery.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(lastQuery);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      state = const AsyncValue.loading();

      final response = await Supabase.instance.client
          .from('items')
          .select()
          .or(
            'product_name.ilike.%$query%,'
            'supplier_name.ilike.%$query%,'
            'category_name.ilike.%$query%',
          )
          .order('created_at', ascending: false)
          .limit(50)
          .timeout(const Duration(seconds: 10));

      final result = (response as List)
          .map((e) => ProductListModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(result);
    } on SocketException {
      state = const AsyncValue.data([]);
    } on TimeoutException {
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    if (lastQuery.isEmpty) {
      // optional: keep empty result or early return
      return;
    }
    await _performSearch(lastQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final productSearchNotifierProvider =
    StateNotifierProvider<
      ProductSearchNotifier,
      AsyncValue<List<ProductListModel>>
    >((ref) => ProductSearchNotifier());
