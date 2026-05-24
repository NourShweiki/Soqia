// auth_gate.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';
import '../screens/login_screen.dart';
import '../screens/verify_email_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        print('Connection state: ${snapshot.connectionState}'); // 👈 add
        print('Has data: ${snapshot.hasData}'); // 👈 add

        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Showing loading'); // 👈 add
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;
        print('Session: $session'); // 👈 add

        if (session == null) {
          print('Showing login'); // 👈 add
          return const LoginScreen();
        }

        final user = session.user;
        print('User verified: ${user.emailConfirmedAt}'); // 👈 add

        if (user.emailConfirmedAt == null) {
          print('Showing verify'); // 👈 add
          return VerifyEmailScreen(email: user.email ?? '');
        }

        print('Showing dashboard'); // 👈 add
        return DashboardScreen();
      },
    );
  }


}