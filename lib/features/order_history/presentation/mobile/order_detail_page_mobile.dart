import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/message/presentation/mobile/chat_page.dart';
import 'package:mandalar_x/features/order_history/model/order_item_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class OrderDetailPageMobile extends ConsumerWidget {
  final OrderModel order;

  const OrderDetailPageMobile({super.key, required this.order});

  String getFormattedPrice(double price) {
    return price.truncateToDouble() == price
        ? price.toInt().toString()
        : price.toStringAsFixed(2);
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  Future<String> getOrCreateChatRoom(String merchantId) async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception("You must be logged in to chat");
    }

    final response = await Supabase.instance.client.rpc(
      'get_or_create_room',
      params: {'user_a': currentUserId, 'user_b': merchantId},
    );

    if (response is String) return response;
    if (response is List && response.isNotEmpty) return response[0].toString();
    return response.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = order.items.fold<double>(
        0, (sum, item) => sum + (item.price * item.quantity));
    const deliveryFee = 1500;
    final total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: AppColors.appBackground,
        centerTitle: true,
        title: Text(
          'Order Details',
          style: AppFontStyle.label.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.labelColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Order Items
          Text(
            'Order Items',
            style: AppFontStyle.title.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          ...order.items.map((item) => Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 8),
                  ],
                ),
                child: Row(
                  children: [
                    if (item.productImage.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.productImage,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: AppFontStyle.label.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Price: MMK ${item.price}'),
                          Text('Quantity: ${item.quantity}'),
                        ],
                      ),
                    ),
                  ],
                ),
              )),

          const Divider(height: 24),

          // Order Summary
          Text(
            'Order Summary',
            style: AppFontStyle.label.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('MMK $subtotal'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Delivery Fee'),
              Text('MMK $deliveryFee'),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'MMK $total',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Button to message merchant
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                final roomId = await getOrCreateChatRoom(order.ownerId);
                if (!context.mounted) return;
                final currentUserId =
                    Supabase.instance.client.auth.currentUser?.id ?? '';
                if (currentUserId.isEmpty) throw Exception("Not logged in");

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPage(
                      roomId: roomId,
                      currentUserId: currentUserId,
                    ),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to open chat: $e')),
                );
              }
            },
            child: Text(
              'Message Merchant',
              style: AppFontStyle.caption.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
