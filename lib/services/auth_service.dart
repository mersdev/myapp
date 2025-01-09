import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  String? get currentUserId => currentUser?.id;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<void> signUp(String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'io.supabase.cognitive://login-callback/',
    );
    
    if (response.user == null) {
      throw const AuthException('Failed to create account');
    }
  }

  Future<void> signIn(String email, String password) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> resendVerificationEmail() async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException('No user logged in');
    }

    await _supabase.auth.resend(
      type: OtpType.signup,
      email: user.email,
    );
  }
} 