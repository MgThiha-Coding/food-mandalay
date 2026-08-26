import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignOutNotifier extends StateNotifier<AsyncValue<void>> {
  SignOutNotifier(this._supabase) : super(const AsyncValue.data(null));

  final SupabaseClient _supabase;

  Future<void> signOut() async {
    state = AsyncValue.loading();
    try {
      await _supabase.auth.signOut();
      // Delay ensures state propagation before UI reacts
      Future.delayed(const Duration(milliseconds: 100), () {
        state = const AsyncValue.data(null);
      });
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
}

// Provider for SignOutNotifier
final signOutNotifierProvider =
    StateNotifierProvider<SignOutNotifier, AsyncValue<void>>(
  (ref) => SignOutNotifier(Supabase.instance.client),
);
