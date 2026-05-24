import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import 'verify_email_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        // Success — go to verify email screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VerifyEmailScreen(
                email: _emailController.text.trim(),
              ),
            ),
          );
        }
      }

    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      print('Sign up error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Soft blue gradient matching the login screen theme
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // White Floating Form Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // App Branding Image Asset Placeholder
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Image.asset(
                                'assets/images/soqia_logo.png', // 👈 Replace with your actual project logo path string
                                height: 60,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback layout block text in case the asset path is unlinked or missing
                                  return Column(
                                    children: [
                                      const Text(
                                        "SOQIA",
                                        style: TextStyle(
                                          fontSize: 34,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2B70D6),
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Innovative Environmental Solutions",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Full Name Label & Field
                          const Text(
                            "Full Name",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            style: const TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: "Your Name",
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(color: Color(0xFF00B4DB), width: 1.5),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              if (value.trim().length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Email Label & Field
                          const Text(
                            "Email Address",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: "you@example.com",
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(color: Color(0xFF00B4DB), width: 1.5),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email (must contain @)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Password Label & Field
                          const Text(
                            "Password",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: "••••••••",
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey.shade500,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(color: Color(0xFF00B4DB), width: 1.5),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Password is required";
                              }
                              if (value.length < 4) {
                                return "Password must be at least 4 characters";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Confirm Password Label & Field
                          const Text(
                            "Confirm Password",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: const TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: "••••••••",
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey.shade500,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(color: Color(0xFF00B4DB), width: 1.5),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Confirming your password is required";
                              }
                              if (value != _passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // Sign Up Action Button with Gradient
                          GestureDetector(
                            onTap: _isLoading ? null : _signUp,
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
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                                    : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bottom Return Link
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Color(0xFF718096), fontSize: 14),
                      children: [
                        const TextSpan(text: "Have an Account? "),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Log in",
                              style: TextStyle(
                                color: Color(0xFF3883FF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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