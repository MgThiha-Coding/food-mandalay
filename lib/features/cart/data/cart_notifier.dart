import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/features/cart/model/cart_product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartNotifier extends StateNotifier<AsyncValue<List<CartProductModel>>> {
  CartNotifier() : super(const AsyncValue.data([]));

  Future<void> fetchCartItems() async {
    try {
      state = const AsyncValue.loading();

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception("User not logged in");

      final response = await Supabase.instance.client
          .from('cart')
          .select('*, product:product_id(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 10));

      final cartItems = (response as List<dynamic>).map((e) {
        final Map<String, dynamic> json = Map<String, dynamic>.from(e);
        final Map<String, dynamic> productJson = Map<String, dynamic>.from(
          json['product'] ?? {},
        );
        final mergedJson = {...productJson, ...json};
        return CartProductModel.fromJson(mergedJson);
      }).toList();

      state = AsyncValue.data(cartItems);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception("User not logged in");

      final response = await Supabase.instance.client
          .from('cart')
          .select('*, product:product_id(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 10));

      final cartItems = (response as List<dynamic>).map((e) {
        final Map<String, dynamic> json = Map<String, dynamic>.from(e);
        final Map<String, dynamic> productJson = Map<String, dynamic>.from(
          json['product'] ?? {},
        );
        final mergedJson = {...productJson, ...json};
        return CartProductModel.fromJson(mergedJson);
      }).toList();

      state = AsyncValue.data(cartItems);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add or update cart item
  Future<bool> addToCart({
    required String productId,
    int itemCount = 1,
    String? selectedSpicyLevel,
    String? selectedSweetLevel,
    String? selectedSourLevel,
  }) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception("User not logged in");

      final existing = await Supabase.instance.client
          .from('cart')
          .select()
          .eq('product_id', productId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        await Supabase.instance.client
            .from('cart')
            .update({
              'item_count': itemCount,
              'selected_spicy_level': selectedSpicyLevel,
              'selected_sweet_level': selectedSweetLevel,
              'selected_sour_level': selectedSourLevel,
            })
            .eq('product_id', productId)
            .eq('user_id', userId);
      } else {
        await Supabase.instance.client.from('cart').insert({
          'user_id': userId,
          'product_id': productId,
          'item_count': itemCount,
          'selected_spicy_level': selectedSpicyLevel,
          'selected_sweet_level': selectedSweetLevel,
          'selected_sour_level': selectedSourLevel,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      await fetchCartItems();
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> incrementItem(String productId) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final item = await Supabase.instance.client
          .from('cart')
          .select('item_count')
          .eq('product_id', productId)
          .eq('user_id', userId)
          .single();

      final currentCount = item['item_count'] as int;

      await Supabase.instance.client
          .from('cart')
          .update({'item_count': currentCount + 1})
          .eq('product_id', productId)
          .eq('user_id', userId);

      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> decrementItem(String productId) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final item = await Supabase.instance.client
          .from('cart')
          .select('item_count')
          .eq('product_id', productId)
          .eq('user_id', userId)
          .single();

      final currentCount = item['item_count'] as int;

      if (currentCount <= 1) {
        await Supabase.instance.client
            .from('cart')
            .delete()
            .eq('product_id', productId)
            .eq('user_id', userId);
      } else {
        await Supabase.instance.client
            .from('cart')
            .update({'item_count': currentCount - 1})
            .eq('product_id', productId)
            .eq('user_id', userId);
      }

      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Clear all cart items
  Future<void> clearCart() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception("User not logged in");

      await Supabase.instance.client
          .from('cart')
          .delete()
          .eq('user_id', userId);

      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Remove cart item
  Future<void> removeFromCart(String productId) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception("User not logged in");

      await Supabase.instance.client
          .from('cart')
          .delete()
          .eq('product_id', productId)
          .eq('user_id', userId);
      await fetchCartItems();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<List<CartProductModel>>>(
      (ref) => CartNotifier(),
    );
