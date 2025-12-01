import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client.auth);
});

class AuthRepository {
  final GoTrueClient _auth;

  AuthRepository(this._auth);

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  User? get currentUser => _auth.currentUser;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      // WEB IMPLEMENTATION: Use Supabase Redirect Flow
      // The google_sign_in plugin on web often fails to return an ID token (returns null).
      // Supabase's native OAuth flow handles this reliably via redirect.
      if (const bool.fromEnvironment('dart.library.js_util')) {
        await _auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'http://localhost:5000', // Matches your fixed port
          authScreenLaunchMode: LaunchMode.platformDefault,
        );
        return; // Flow continues after redirect
      }

      // MOBILE IMPLEMENTATION: Use google_sign_in plugin
      // IMPORTANT: For Supabase, we need to provide the Web Client ID as serverClientId
      // This ensures Google returns an ID token that Supabase can verify
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId:
            '694281481988-p48usnffnarftfcelog9147426dkef92.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      await _auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
