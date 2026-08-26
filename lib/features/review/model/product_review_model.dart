class ProductReviewModel {
  final int productId;
  final String reviews;
  final String? userEmail;
  final DateTime createdAt;

  ProductReviewModel({
    required this.productId,
    required this.reviews,
    this.userEmail,
    required this.createdAt,
  });

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    return ProductReviewModel(
      productId: json['product_id'],
      reviews: json['reviews'],
      userEmail: json['user_email'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'reviews': reviews,
      'user_email': userEmail,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
