import 'package:flutter/material.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';

class CategoryListSection extends StatelessWidget {
  final List categoryList;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryListSection({
    super.key,
    required this.categoryList,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.08,
      margin: const EdgeInsets.symmetric(horizontal: 8,),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categoryList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryItem(
              name: 'All',
              isSelected: selectedCategory.isEmpty,
              onTap: () => onCategorySelected(''),
            );
          }
          final categoryName =
              categoryList[index - 1].categoryName ?? 'Unknown';
          return _CategoryItem(
            name: categoryName,
            isSelected: selectedCategory == categoryName,
            onTap: () => onCategorySelected(categoryName),
          );
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3, // small float effect
        color: Colors.transparent, // let container handle the color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.black26, // subtle shadow
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? Colors.red : Colors.white,
          ),
          child: Center(
            child: Text(
              name,
              style: AppFontStyle.caption.copyWith(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
