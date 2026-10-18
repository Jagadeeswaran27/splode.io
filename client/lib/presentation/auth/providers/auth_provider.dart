import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:google_sign_in/google_sign_in.dart' as gsi;

/// Provides a stream of AuthState changes from Supabase.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Provides the currently authenticated Supabase User, or null if logged out.
final currentUserProvider = Provider<User?>((ref) {
  // Watch the auth state stream to trigger rebuilds on login/logout
  final authState = ref.watch(authStateProvider).value;
  return authState?.session?.user ?? Supabase.instance.client.auth.currentUser;
});

/// Provides access to authentication actions (signIn, signOut, etc.)
final authLogicProvider = Provider<AuthLogic>((ref) {
  return AuthLogic();
});

class AuthLogic {
  final _supabase = Supabase.instance.client;

  /// Signs the user in using Google Auth via native sheet.
  Future<void> signInWithGoogle({required String webClientId}) async {
    // 1. Initialize the singleton
    await gsi.GoogleSignIn.instance.initialize(serverClientId: webClientId);

    // 2. Ensure we start fresh
    await gsi.GoogleSignIn.instance.signOut();

    // 3. Authenticate
    final gsi.GoogleSignInAccount googleUser = await gsi.GoogleSignIn.instance
        .authenticate();

    // 4. Retrieve tokens
    final gsi.GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw 'No ID Token found.';
    }

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  /// Signs the user in anonymously (Guest Mode).
  /// This creates a permanent, real user in Supabase but without credentials.
  /// A row will automatically be created in the `profiles` table via triggers.
  Future<void> signInAnonymously() async {
    await _supabase.auth.signInAnonymously();
  }

  /// Signs the user out.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
