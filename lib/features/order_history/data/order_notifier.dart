import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/features/cart/model/cart_product_model.dart';
import 'package:mandalar_x/features/order_history/model/order_item_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const double deliveryFeePerRestaurant = 1500.0;

class OrderNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  OrderNotifier() : super(const AsyncValue.data([]));

  /// Generate unique order ID
  String _generateFoodMandalayOrderId() {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final unique = (now.microsecondsSinceEpoch % 100000).toString().padLeft(
      5,
      '0',
    );
    return 'FM-$date-$unique';
  }

  /// Place order and notify merchants
  Future<bool> placeOrder({
    required List<CartProductModel> cartItems,
    required Map<String, dynamic> deliveryLocation,
    required String userName,
    required String userPhone,
    required String deliveryInstructions,
  }) async {
    if (cartItems.isEmpty) return false;

    state = const AsyncValue.loading();

    try {
      // Map cart items to order items using ownerId
      final orderItems = cartItems
          .map((e) => OrderItemModel.fromCart(e))
          .toList();

      // Group items by ownerId
      final Map<String, List<OrderItemModel>> groupedByOwner = {};
      for (final item in orderItems) {
        groupedByOwner.putIfAbsent(item.ownerId, () => []).add(item);
      }

      final List<OrderModel> createdOrders = [];
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) throw Exception('User not logged in');

      for (final entry in groupedByOwner.entries) {
        final ownerId = entry.key;
        final items = entry.value;

        final subtotal = items.fold<double>(
          0,
          (sum, item) => sum + (item.price * item.quantity),
        );
        const deliveryFee = deliveryFeePerRestaurant;
        final total = subtotal + deliveryFee;

        final order = OrderModel(
          userName: userName,
          userPhone: userPhone,
          userId: currentUserId,
          status: 'pending',
          orderId: _generateFoodMandalayOrderId(),
          ownerId: ownerId, // use ownerId instead of supplierId
          items: items,
          subtotal: subtotal,
          deliveryFee: deliveryFee,
          total: total,
          deliveryLocation: deliveryLocation,
          deliveryInstructions: deliveryInstructions,
          createdAt: DateTime.now(),
        );

        // Insert order into Supabase
        await Supabase.instance.client.from('order').insert(order.toMap());

        createdOrders.add(order);
      }

      state = AsyncValue.data(createdOrders);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Fetch order history for current user
  Future<void> fetchOrderHistory() async {
    state = const AsyncValue.loading();

    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) throw Exception('User not logged in');

      final response = await Supabase.instance.client
          .from('order')
          .select()
          .eq('user_id', currentUserId);

      final orders = (response as List<dynamic>)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<List<OrderModel>>>(
      (ref) => OrderNotifier(),
    );
