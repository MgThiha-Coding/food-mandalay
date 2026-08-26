import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/features/review/model/product_review_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductReviewNotifier
    extends StateNotifier<AsyncValue<List<ProductReviewModel>>> {
  ProductReviewNotifier() : super(const AsyncValue.data([]));

  /// Fetch all reviews for a product
  Future<void> fetchReviews(int productId) async {
    try {
      state = AsyncValue.loading();

      final response = await Supabase.instance.client
          .from('reviews')
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 10));

      final reviews = (response as List<dynamic>)
          .map((e) => ProductReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(reviews);
    } catch (error, st) {
      state = AsyncValue.error(error, st);
    }
  }

  /// Add a new review with the authenticated user's email
  Future<void> addReview({
    required String productId,
    required String reviewText,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final userEmail = user.email ?? 'Anonymous';

      final response = await Supabase.instance.client
          .from('reviews')
          .insert({
            'product_id': productId,
            'reviews': reviewText,
            'user_email': userEmail,
          })
          .select()
          .timeout(const Duration(seconds: 10));

      final insertedReviews = (response as List<dynamic>)
          .map((e) => ProductReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final currentReviews = state.value ?? [];
      state = AsyncValue.data([...insertedReviews, ...currentReviews]);
    } catch (error, st) {
      state = AsyncValue.error(error, st);
    }
  }
}

final productReviewNotifierProvider =
    StateNotifierProvider<ProductReviewNotifier, AsyncValue<List<ProductReviewModel>>>(
  (ref) => ProductReviewNotifier(),
);
