// verify_email_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soqia1/features/auth/screens/login_screen.dart';

class VerifyEmailScreen extends StatelessWidget {
  final String email;              // 👈 we pass the email to display it
  const VerifyEmailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Consistent theme background gradient
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F5FF),
              Color(0xFFF1F9FF),
              Color(0xFFE5F6FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // White Floating Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Branding Image Asset Placeholder
                        Image.asset(
                          'assets/images/soqia_logo.png', // 👈 Matches your path structure
                          height: 50,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                              "SOQIA",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2B70D6),
                                letterSpacing: 2,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // 🔵 Big icon — email/envelope feel (with soft background circle)
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 10.0),
                          duration: const Duration(seconds: 2),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, value - 5),
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE3F5FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.mark_email_unread_outlined,
                              size: 54,
                              color: Color(0xFF3883FF),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Main Header Text
                        const Text(
                          'Verify your email',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 🔵 Show which email was used
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF718096),
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: "We sent a verification link to\n"),
                              TextSpan(
                                text: email,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 🔵 Back to Login button with Theme Gradient
                        GestureDetector(
                          onTap: () {
                            // Clear the whole navigation stack and go back to login
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false,   // 👈 removes all previous routes
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF3883FF),
                                  Color(0xFF00B4DB),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00B4DB).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Back to Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 🔵 Small note
                        const Text(
                          "Check your spam folder if you don't see it",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xA3718096),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}