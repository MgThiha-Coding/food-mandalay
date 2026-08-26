class RestaurantListModel {
  final String? restaurantId;
  final String? ownerId;
  final String? name;
  final String? description;
  final String? image;
  final bool? isOpen;
  final DateTime? createdAt;

  RestaurantListModel({
    this.restaurantId,
    this.ownerId,
    this.name,
    this.description,
    this.image,
    this.isOpen,
    this.createdAt,
  });

  factory RestaurantListModel.fromJson(Map<String, dynamic> json) {
    return RestaurantListModel(
      restaurantId: json['restaurant_id']?.toString(),
      ownerId: json['owner_id']?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      isOpen: json['is_open'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurant_id': restaurantId,
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'image': image,
      'is_open': isOpen,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
