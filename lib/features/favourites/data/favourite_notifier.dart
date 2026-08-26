import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/features/favourites/model/favourite_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavouriteNotifier
    extends StateNotifier<AsyncValue<List<FavouriteModel>>> {
  FavouriteNotifier() : super(const AsyncValue.loading()) {
    fetchFavourites();
  }

  final _client = Supabase.instance.client;

  Future<void> fetchFavourites() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final response = await _client
          .from('favourites')
          .select()
          .eq('user_id', userId);

      final favourites = (response as List)
          .map((e) => FavouriteModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(favourites);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFavourite({
    required String targetId,
    required String targetType,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final existing = await _client
          .from('favourites')
          .select('id')
          .eq('user_id', userId)
          .eq('target_id', targetId)
          .eq('target_type', targetType)
          .maybeSingle();

      if (existing != null) {
        await _client
            .from('favourites')
            .delete()
            .eq('id', existing['id']);
      } else {
        await _client.from('favourites').insert({
          'user_id': userId,
          'target_id': targetId,
          'target_type': targetType,
        });
      }

      await fetchFavourites();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final favouriteNotifierProvider =
    StateNotifierProvider<FavouriteNotifier, AsyncValue<List<FavouriteModel>>>(
  (ref) => FavouriteNotifier(),
);
