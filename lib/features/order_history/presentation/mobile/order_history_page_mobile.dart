import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/message/presentation/mobile/chat_page.dart';
import 'package:mandalar_x/features/order_history/data/order_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderHistoryPageMobile extends ConsumerStatefulWidget {
  const OrderHistoryPageMobile({super.key});

  @override
  ConsumerState<OrderHistoryPageMobile> createState() =>
      _OrderHistoryPageMobileState();
}

class _OrderHistoryPageMobileState
    extends ConsumerState<OrderHistoryPageMobile> {
  final Map<String, bool> _showAllItems = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderNotifierProvider.notifier).fetchOrderHistory();
    });
  }

  String getFormattedPrice(double price) {
    return price.truncateToDouble() == price
        ? price.toInt().toString()
        : price.toStringAsFixed(2);
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.appBackground,
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Order History",
          style: AppFontStyle.title.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ),
      backgroundColor: AppColors.appBackground,
      body: orderState.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.red)),
        error: (error, _) => Center(
          child: Text(
            "Failed to load orders",
            style: AppFontStyle.caption.copyWith(color: Colors.grey),
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Text(
                "No orders found",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            color: Colors.red,
            backgroundColor: Colors.white,
            onRefresh: () async {
              await ref
                  .read(orderNotifierProvider.notifier)
                  .fetchOrderHistory();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                final orderId = order.orderId;
                final showAll = _showAllItems[orderId] ?? false;
                final displayItems = showAll
                    ? order.items
                    : order.items.take(2).toList();

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            orderId,
                            style: AppFontStyle.label.copyWith(
                              color: Colors.green,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: order.status == "pending"
                                  ? Colors.orange.shade100
                                  : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order.status.toUpperCase(),
                              style: TextStyle(
                                color: order.status == "pending"
                                    ? Colors.orange
                                    : Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatDate(order.createdAt),
                        style: AppFontStyle.caption.copyWith(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...displayItems.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "${item.quantity} x ${item.productName}",
                                  style: AppFontStyle.caption,
                                ),
                              ),
                              Text(
                                "MMK ${getFormattedPrice(item.price * item.quantity)}",
                                style: AppFontStyle.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (order.items.length > 2)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showAllItems[orderId] = !showAll;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              showAll ? "See less" : "See all",
                              style: AppFontStyle.caption.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${order.items.fold<int>(0, (sum, e) => sum + e.quantity)} item(s)",
                            style: AppFontStyle.caption,
                          ),
                          Text(
                            "MMK ${getFormattedPrice(order.total)}",
                            style: AppFontStyle.label.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            final sender =
                                Supabase.instance.client.auth.currentUser;
                            if (sender == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'You must be logged in to chat',
                                  ),
                                ),
                              );
                              return;
                            }

                            final senderId = sender.id;
                            final merchantId = order.ownerId;

                            // Show loading dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            // Call RPC to get or create chat room
                            final response = await Supabase.instance.client.rpc(
                              'get_or_create_room',
                              params: {
                                'user_a': senderId,
                                'user_b': merchantId,
                              },
                            );
                            if (!context.mounted) return;

                            String roomId;
                            if (response is String) {
                              roomId = response;
                            } else if (response is List &&
                                response.isNotEmpty) {
                              roomId = response[0].toString();
                            } else {
                              roomId = response.toString();
                            }

                            Navigator.pop(context); // Close loading dialog

                            // Navigate to ChatPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPage(
                                  roomId: roomId,
                                  currentUserId: senderId,
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            Navigator.pop(context); // Close loading if error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to open chat: $e'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.message,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          'Contact Merchant',
                          style: AppFontStyle.caption.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
