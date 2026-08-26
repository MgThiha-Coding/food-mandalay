class CartProductModel {
  final String productId;
  final int itemCount;
  final String? selectedSpicyLevel;
  final String? selectedSweetLevel;
  final String? selectedSourLevel;
  final String? supplierId;
  final String? ownerId;
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
  final bool? isSpicyLevelEnabled;
  final bool? isSweetLevelEnabled;
  final bool? isSourLevelEnabled;
  final String? productImage;
  final List<String> productColorNames;
  final List<Map<String, dynamic>> productVariants;
  final double discount;

  CartProductModel({
    required this.productId,
    required this.itemCount,
    this.selectedSpicyLevel,
    this.selectedSweetLevel,
    this.selectedSourLevel,
    this.supplierId,
    this.ownerId,
    this.productName,
    this.supplierName,
    this.brandName,
    this.categoryName,
    this.sku,
    this.price,
    this.stock,
    this.description,
    List<String>? productSize,
    this.productWeight,
    this.shopOpenTime,
    this.shopCloseTime,
    this.deliveryStartTime,
    this.deliveryEndTime,
    this.createdAt,
    this.updatedAt,
    this.isActive,
    this.status,
    this.isSpicyLevelEnabled,
    this.isSweetLevelEnabled,
    this.isSourLevelEnabled,
    this.productImage,
    List<String>? productColorNames,
    List<Map<String, dynamic>>? productVariants,
    this.discount = 0.0,
  })  : productSize = productSize ?? [],
        productColorNames = productColorNames ?? [],
        productVariants = productVariants ?? [];

  double get finalPrice => price != null ? price! * (1 - discount / 100) : 0;

  CartProductModel copyWith({
    String? productId,
    int? itemCount,
    String? selectedSpicyLevel,
    String? selectedSweetLevel,
    String? selectedSourLevel,
    String? supplierId,
    String? ownerId, // NEW FIELD
    String? productName,
    String? supplierName,
    String? brandName,
    String? categoryName,
    String? sku,
    double? price,
    int? stock,
    String? description,
    List<String>? productSize,
    String? productWeight,
    DateTime? shopOpenTime,
    DateTime? shopCloseTime,
    DateTime? deliveryStartTime,
    DateTime? deliveryEndTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? status,
    bool? isSpicyLevelEnabled,
    bool? isSweetLevelEnabled,
    bool? isSourLevelEnabled,
    String? productImage,
    List<String>? productColorNames,
    List<Map<String, dynamic>>? productVariants,
    double? discount,
  }) {
    return CartProductModel(
      productId: productId ?? this.productId,
      itemCount: itemCount ?? this.itemCount,
      selectedSpicyLevel: selectedSpicyLevel ?? this.selectedSpicyLevel,
      selectedSweetLevel: selectedSweetLevel ?? this.selectedSweetLevel,
      selectedSourLevel: selectedSourLevel ?? this.selectedSourLevel,
      supplierId: supplierId ?? this.supplierId,
      ownerId: ownerId ?? this.ownerId, // NEW FIELD
      productName: productName ?? this.productName,
      supplierName: supplierName ?? this.supplierName,
      brandName: brandName ?? this.brandName,
      categoryName: categoryName ?? this.categoryName,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      productSize: productSize ?? this.productSize,
      productWeight: productWeight ?? this.productWeight,
      shopOpenTime: shopOpenTime ?? this.shopOpenTime,
      shopCloseTime: shopCloseTime ?? this.shopCloseTime,
      deliveryStartTime: deliveryStartTime ?? this.deliveryStartTime,
      deliveryEndTime: deliveryEndTime ?? this.deliveryEndTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      isSpicyLevelEnabled: isSpicyLevelEnabled ?? this.isSpicyLevelEnabled,
      isSweetLevelEnabled: isSweetLevelEnabled ?? this.isSweetLevelEnabled,
      isSourLevelEnabled: isSourLevelEnabled ?? this.isSourLevelEnabled,
      productImage: productImage ?? this.productImage,
      productColorNames: productColorNames ?? this.productColorNames,
      productVariants: productVariants ?? this.productVariants,
      discount: discount ?? this.discount,
    );
  }

  factory CartProductModel.fromJson(Map<String, dynamic> json) {
    return CartProductModel(
      productId: json['product_id']?.toString() ?? '',
      itemCount: json['item_count'] ?? 1,
      selectedSpicyLevel: json['selected_spicy_level']?.toString(),
      selectedSweetLevel: json['selected_sweet_level']?.toString(),
      selectedSourLevel: json['selected_sour_level']?.toString(),
      supplierId: json['supplier_id']?.toString(),
      ownerId: json['owner_id']?.toString(), // NEW FIELD
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
          : json['product_size'] is String
              ? json['product_size'].toString().split(',').map((e) => e.trim()).toList()
              : [],
      productWeight: json['product_weight']?.toString(),
      shopOpenTime: json['shop_open_time'] != null ? DateTime.tryParse(json['shop_open_time'].toString()) : null,
      shopCloseTime: json['shop_close_time'] != null ? DateTime.tryParse(json['shop_close_time'].toString()) : null,
      deliveryStartTime: json['delivery_start_time'] != null ? DateTime.tryParse(json['delivery_start_time'].toString()) : null,
      deliveryEndTime: json['delivery_end_time'] != null ? DateTime.tryParse(json['delivery_end_time'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      isActive: json['is_active'] as bool?,
      status: json['status']?.toString(),
      isSpicyLevelEnabled: json['is_spicy_level_enabled'] as bool?,
      isSweetLevelEnabled: json['is_sweet_level_enabled'] as bool?,
      isSourLevelEnabled: json['is_sour_level_enabled'] as bool?,
      productImage: json['product_image'] != null
          ? json['product_image'].toString()
          : (json['product_images'] is List && (json['product_images'] as List).isNotEmpty)
              ? json['product_images'][0].toString()
              : null,
      productColorNames: (json['product_color_names'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      productVariants: (json['product_variants'] as List<dynamic>?)
              ?.map((v) => Map<String, dynamic>.from(v))
              .toList() ?? [],
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'item_count': itemCount,
      'selected_spicy_level': selectedSpicyLevel,
      'selected_sweet_level': selectedSweetLevel,
      'selected_sour_level': selectedSourLevel,
      'supplier_id': supplierId,
      'owner_id': ownerId, // NEW FIELD
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
      'is_spicy_level_enabled': isSpicyLevelEnabled,
      'is_sweet_level_enabled': isSweetLevelEnabled,
      'is_sour_level_enabled': isSourLevelEnabled,
      'product_image': productImage,
      'product_color_names': productColorNames,
      'product_variants': productVariants,
      'discount': discount,
    };
  }
}
