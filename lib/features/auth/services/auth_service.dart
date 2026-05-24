// lib/features/auth/services/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';

class AuthService {

  // ── Sign Up ────────────────────────────────────────────
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,  // we'll handle this differently
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},  // 👈 pass name as metadata
    );

    // No manual insert needed - the trigger creates the profile!

    return response;
  }

  // ── Login ──────────────────────────────────────────────
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ── Logout ─────────────────────────────────────────────
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  // ── Current user (null if not logged in) ───────────────
  User? get currentUser => supabase.auth.currentUser;
}