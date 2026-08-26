import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mandalar_x/features/auth/model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  SignUpNotifier(this._supabase) : super(const AsyncValue.data(null));

  final SupabaseClient _supabase;

  // =========================
  // Email / Password Sign Up
  // =========================
  Future<void> signUp(UserModel params) async {
    state = const AsyncValue.loading();
    try {
      final response = await _supabase.auth.signUp(
        email: params.email,
        password: params.password!,
      );

      final user = response.user;
      if (user == null) {
        throw AuthException('Sign up failed');
      }

      state = AsyncValue.data(UserModel(id: user.id, email: user.email ?? ''));
    } catch (e, st) {
      debugPrint('Sign up error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  // =========================
  // Google Sign-In (Android) - FIXED
  // =========================
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    
    try {
      const webClientId =
          '295913876442-mb9jei1pj95vlm00rrvgsji5tnbifahh.apps.googleusercontent.com';

      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(serverClientId: webClientId);

      final googleUser = await googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw AuthException('Missing Google ID token');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      final user = response.user;
      if (user == null) {
        throw AuthException('Supabase Google sign-in failed');
      }

      state = AsyncValue.data(UserModel(id: user.id, email: user.email ?? ''));
    } on GoogleSignInException catch (e, st) {
      // ✅ FIX 3: Handle cancel properly (no toast)
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint('User cancelled Google sign-in: $e');
        state = const AsyncValue.data(null);
        return;
      }
      debugPrint('Google Sign-In error: $e');
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      debugPrint('Google Sign-In error: $e');
      state = AsyncValue.error(e, st);
    }
  }
}

final signUpNotifierProvider =
    StateNotifierProvider<SignUpNotifier, AsyncValue<UserModel?>>(
      (ref) => SignUpNotifier(Supabase.instance.client),
    );
