import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/features/category/model/category_list_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryListNotifier
    extends StateNotifier<AsyncValue<List<CategoryListModel>>> {
  CategoryListNotifier() : super(const AsyncValue.data([]));

  Future<void> fetchCategoryList() async {
    try {
      state = AsyncValue.loading();

      final response = await Supabase.instance.client
          .from('category')
          .select()
          .order('created_at', ascending: false)
          .timeout(Duration(seconds: 10));

      final categories = (response as List<dynamic>)
          .map((e) => CategoryListModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(categories);
    } catch (error, st) {
      state = AsyncValue.error(error, st);
    }
  }
}

final categoryListNotifierProvider =
    StateNotifierProvider<
      CategoryListNotifier,
      AsyncValue<List<CategoryListModel>>
    >((ref) => CategoryListNotifier());
