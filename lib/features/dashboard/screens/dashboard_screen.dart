// dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.water_drop, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Welcome to Soqia!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Logged in as: ${user?.email ?? "Unknown"}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const Text(
              '🚧 Configuration page coming soon...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}