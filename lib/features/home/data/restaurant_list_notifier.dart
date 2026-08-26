import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/features/home/model/restaurant_list_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class RestaurantListNotifier
    extends StateNotifier<AsyncValue<List<RestaurantListModel>>> {
  RestaurantListNotifier() : super(const AsyncValue.data([])) {
    fetchRestaurants();
  }

  static const int _pageSize = 20;

  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;

  Future<void> fetchRestaurants({int page = 0, int pageSize = _pageSize}) async {
    if (_isLoading || !_hasMore) return;

    try {
      _isLoading = true;

      if (_currentPage == 0) {
        state = const AsyncValue.loading();
      }

      final start = _currentPage * _pageSize;
      final end = start + _pageSize - 1;

      final response = await Supabase.instance.client
          .from('restaurants')
          .select()
          .order('created_at', ascending: false)
          .range(start, end)
          .timeout(const Duration(seconds: 10));

      final newItems = (response as List)
          .map((e) => RestaurantListModel.fromJson(e as Map<String, dynamic>))
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

final restaurantListNotifierProvider =
    StateNotifierProvider<RestaurantListNotifier, AsyncValue<List<RestaurantListModel>>>(
        (ref) => RestaurantListNotifier());
