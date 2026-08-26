class FavouriteModel {
  final String userId;
  final String targetId;
  final String targetType;

  FavouriteModel({
    required this.userId,
    required this.targetId,
    required this.targetType,
  });

  factory FavouriteModel.fromJson(Map<String, dynamic> json) {
    return FavouriteModel(
      userId: json['user_id'] as String,
      targetId: json['target_id'] as String,
      targetType: json['target_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'target_id': targetId,
      'target_type': targetType,
    };
  }
}
