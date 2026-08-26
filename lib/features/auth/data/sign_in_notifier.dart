import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/features/auth/model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  SignInNotifier(this._supabase) : super(const AsyncValue.data(null));

  final SupabaseClient _supabase;

  Future<void> signIn(UserModel params) async {
    state = AsyncValue.loading();
    try {
      final response = await _supabase.auth
          .signInWithPassword(email: params.email, password: params.password!)
          .timeout(Duration(seconds: 10));

      if (response.user != null) {
        final user = response.user;
        final userModel = UserModel(id: user!.id, email: user.email);
        state = AsyncValue.data(userModel);
      } else {
        // error
      }
    } catch (e,st) {
       state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = AsyncValue.loading();
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback',
      );
      _supabase.auth.onAuthStateChange.listen((event) {
        final user = event.session?.user;
        if (user != null) {
          state = AsyncValue.data(
            UserModel(id: user.id, email: user.email ?? ''),
          );
        }
      });
    } catch (e,st) {
       state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = AsyncValue.loading();
    try {
      await _supabase.auth.signOut();
      Future.delayed(const Duration(milliseconds: 100), () {
        state = const AsyncValue.data(null);
      });
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
}

final signInNotifierProvider =
    StateNotifierProvider<SignInNotifier, AsyncValue<UserModel?>>(
      (ref) => SignInNotifier(Supabase.instance.client),
    );
