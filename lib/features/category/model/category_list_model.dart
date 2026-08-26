class CategoryListModel {
  final String? categoryName;
  final String? categoryImage;
  CategoryListModel(this.categoryName,this.categoryImage);

  factory CategoryListModel.fromJson(Map<String, dynamic> json) {
    return CategoryListModel(json['categoryName'] as String?,json['categoryImage'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {'categoryName': categoryName,'categoryImage':categoryImage};
  }
}
