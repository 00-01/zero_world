import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_provider.dart';

/// Welcome Screen
/// First screen users see - option to signup, login, or try as guest
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _handleGuestLogin(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    
    // Try to login as guest first
    bool success = await authProvider.login(
      email: 'guest@zeroworld.com',
      password: 'guest123',
    );

    if (!success && context.mounted) {
      // Guest account doesn't exist, create it
      success = await authProvider.signup(
        email: 'guest@zeroworld.com',
        username: 'guest',
        password: 'guest123',
        fullName: 'Guest User',
      );
    }

    if (success && context.mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create guest session'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  const Icon(
                    Icons.air,
                    size: 120,
                    color: Color(0xFFFFFFFF),
                  ),
                  const SizedBox(height: 24),
                  
                  // App name
                  const Text(
                    'Zero World',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tagline
                  const Text(
                    'AI-powered service concierge',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Description
                  const Text(
                    'Order food, book rides, get tasks done\nAll through natural conversation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 64),

                  // Try as Guest button (prominent)
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return ElevatedButton.icon(
                        onPressed: authProvider.isLoading
                            ? null
                            : () => _handleGuestLogin(context),
                        icon: authProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF000000),
                                ),
                              )
                            : const Icon(Icons.explore),
                        label: Text(
                          authProvider.isLoading
                              ? 'Setting up...'
                              : 'Try as Guest',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFFFF),
                          foregroundColor: const Color(0xFF000000),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Info text
                  const Text(
                    'No signup required • Full features',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Divider
                  Row(
                    children: const [
                      Expanded(
                        child: Divider(color: Color(0xFF333333)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Color(0xFF333333)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Sign up button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/signup');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(
                        color: Color(0xFF666666),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Login link
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(
                        color: Color(0xFF888888),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Features
                  _buildFeature(Icons.restaurant, 'Food Delivery'),
                  const SizedBox(height: 12),
                  _buildFeature(Icons.local_taxi, 'Ride Hailing'),
                  const SizedBox(height: 12),
                  _buildFeature(Icons.shopping_cart, 'Groceries'),
                  const SizedBox(height: 12),
                  _buildFeature(Icons.home_repair_service, 'Home Services'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: const Color(0xFF666666),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
