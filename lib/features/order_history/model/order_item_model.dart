import 'package:mandalar_x/features/cart/model/cart_product_model.dart';

class OrderItemModel {
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;
  final String ownerId; 
  final String? selectedSpicyLevel;
  final String? selectedSweetLevel;
  final String? selectedSourLevel;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
    required this.ownerId,
    this.selectedSpicyLevel,
    this.selectedSweetLevel,
    this.selectedSourLevel,
  });

  factory OrderItemModel.fromCart(CartProductModel cart) {
    return OrderItemModel(
      productId: cart.productId,
      productName: cart.productName ?? 'Unknown',
      productImage: cart.productImage ?? '',
      quantity: cart.itemCount,
      price: cart.finalPrice,
      ownerId: cart.ownerId ?? 'unknown', // changed
      selectedSpicyLevel: cart.selectedSpicyLevel,
      selectedSweetLevel: cart.selectedSweetLevel,
      selectedSourLevel: cart.selectedSourLevel,
    );
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id'] as String,
      productName: json['product_name']?.toString() ?? 'Unknown',
      productImage: json['product_image']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      ownerId: json['owner_id']?.toString() ?? 'unknown', // changed
      selectedSpicyLevel: json['selected_spicy_level'] as String?,
      selectedSweetLevel: json['selected_sweet_level'] as String?,
      selectedSourLevel: json['selected_sour_level'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'product_id': productId,
        'product_name': productName,
        'product_image': productImage,
        'quantity': quantity,
        'price': price,
        'owner_id': ownerId, // changed
        'selected_spicy_level': selectedSpicyLevel,
        'selected_sweet_level': selectedSweetLevel,
        'selected_sour_level': selectedSourLevel,
      };
}

class OrderModel {
  final String orderId;
  final String ownerId; 
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final Map<String, dynamic> deliveryLocation;
  final String? deliveryInstructions;
  final String userName;
  final String userPhone;
  final String userId;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.orderId,
    required this.ownerId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.deliveryLocation,
    required this.userName,
    required this.userPhone,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.deliveryInstructions,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      orderId: json['order_id']?.toString() ?? '',
      ownerId: json['owner_id']?.toString() ?? '', // changed
      items: itemsJson
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      deliveryLocation:
          Map<String, dynamic>.from(json['delivery_location'] ?? {}),
      userName: json['user_name']?.toString() ?? 'Unknown',
      userPhone: json['user_phone']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? 'Unknown',
      status: json['status']?.toString() ?? 'pending',
      deliveryInstructions: json['delivery_instructions'] as String?,
      createdAt: DateTime.parse(json['created_at']?.toString() ??
          DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() => {
        'order_id': orderId,
        'owner_id': ownerId, // changed
        'items': items.map((e) => e.toMap()).toList(),
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'total': total,
        'delivery_location': deliveryLocation,
        'user_name': userName,
        'user_phone': userPhone,
        'user_id': userId,
        'status': status,
        'delivery_instructions': deliveryInstructions,
        'created_at': createdAt.toIso8601String(),
      };
}
