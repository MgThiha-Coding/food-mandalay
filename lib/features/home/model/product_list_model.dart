class ProductListModel {
  final String? productId;
  final String? ownerId; // updated from supplierId
  final String? productName;
  final String? supplierName;
  final String? brandName;
  final String? categoryName;
  final String? sku;
  final double? price;
  final int? stock;
  final String? description;
  final List<String> productSize;
  final String? productWeight;
  final DateTime? shopOpenTime;
  final DateTime? shopCloseTime;
  final DateTime? deliveryStartTime;
  final DateTime? deliveryEndTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isActive;
  final String? status;
  final double discount;
  final bool? isSpicyLevelEnabled;
  final bool? isSweetLevelEnabled;
  final bool? isSourLevelEnabled;
  final String? productImage;
  final List<String> productColorNames;
  final List<Map<String, dynamic>> productVariants;

  ProductListModel({
    this.productId,
    this.ownerId,
    this.productName,
    this.supplierName,
    this.brandName,
    this.categoryName,
    this.sku,
    this.price,
    this.stock,
    this.description,
    required this.productSize,
    this.productWeight,
    this.shopOpenTime,
    this.shopCloseTime,
    this.deliveryStartTime,
    this.deliveryEndTime,
    this.createdAt,
    this.updatedAt,
    this.isActive,
    this.status,
    this.discount = 0.0,
    this.isSpicyLevelEnabled,
    this.isSweetLevelEnabled,
    this.isSourLevelEnabled,
    this.productImage,
    List<String>? productColorNames,
    List<Map<String, dynamic>>? productVariants,
  })  : productColorNames = productColorNames ?? [],
        productVariants = productVariants ?? [];

  factory ProductListModel.fromJson(Map<String, dynamic> json) {
    return ProductListModel(
      productId: json['product_id']?.toString(),
      ownerId: json['owner_id']?.toString(), // changed from supplier_id
      productName: json['product_name']?.toString(),
      supplierName: json['supplier_name']?.toString(),
      brandName: json['brand_name']?.toString(),
      categoryName: json['category_name']?.toString(),
      sku: json['sku']?.toString(),
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      stock: json['stock'] != null ? int.tryParse(json['stock'].toString()) : null,
      description: json['description']?.toString(),
      productSize: json['product_size'] is List
          ? List<String>.from(json['product_size'])
          : (json['product_size'] is String
              ? json['product_size']
                  .toString()
                  .split(',')
                  .map((e) => e.trim())
                  .toList()
              : []),
      productWeight: json['product_weight']?.toString(),
      shopOpenTime: json['shop_open_time'] != null
          ? DateTime.tryParse(json['shop_open_time'].toString())
          : null,
      shopCloseTime: json['shop_close_time'] != null
          ? DateTime.tryParse(json['shop_close_time'].toString())
          : null,
      deliveryStartTime: json['delivery_start_time'] != null
          ? DateTime.tryParse(json['delivery_start_time'].toString())
          : null,
      deliveryEndTime: json['delivery_end_time'] != null
          ? DateTime.tryParse(json['delivery_end_time'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      isActive: json['is_active'] as bool?,
      status: json['status']?.toString(),
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : 0.0,
      isSpicyLevelEnabled: json['is_spicy_level_enabled'] as bool?,
      isSweetLevelEnabled: json['is_sweet_level_enabled'] as bool?,
      isSourLevelEnabled: json['is_sour_level_enabled'] as bool?,
      productImage: json['product_image']?.toString(),
      productColorNames: (json['product_color_names'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      productVariants: (json['product_variants'] as List<dynamic>?)
              ?.map((v) => Map<String, dynamic>.from(v))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'owner_id': ownerId, // changed from supplier_id
      'product_name': productName,
      'supplier_name': supplierName,
      'brand_name': brandName,
      'category_name': categoryName,
      'sku': sku,
      'price': price,
      'stock': stock,
      'description': description,
      'product_size': productSize,
      'product_weight': productWeight,
      'shop_open_time': shopOpenTime?.toIso8601String(),
      'shop_close_time': shopCloseTime?.toIso8601String(),
      'delivery_start_time': deliveryStartTime?.toIso8601String(),
      'delivery_end_time': deliveryEndTime?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
      'status': status,
      'discount': discount,
      'is_spicy_level_enabled': isSpicyLevelEnabled,
      'is_sweet_level_enabled': isSweetLevelEnabled,
      'is_sour_level_enabled': isSourLevelEnabled,
      'product_image': productImage,
      'product_color_names': productColorNames,
      'product_variants': productVariants,
    };
  }
}
