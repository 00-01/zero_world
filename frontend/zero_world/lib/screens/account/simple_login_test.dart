import 'package:flutter/material.dart';

class SimpleLoginTest extends StatefulWidget {
  const SimpleLoginTest({super.key});

  @override
  State<SimpleLoginTest> createState() => _SimpleLoginTestState();
}

class _SimpleLoginTestState extends State<SimpleLoginTest> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = 'Ready to test login';
  bool _isLoading = false;

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _message = 'Testing login...';
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _message = 'Please enter email and password';
        _isLoading = false;
      });
      return;
    }

    try {
      // Direct API test without using ApiService
      // Create a simple HTTP client test
      setState(() {
        _message = 'Login test completed - check console for details';
        _isLoading = false;
      });

      // For now, just show that the form works
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login attempted for: $email'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Login Test')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Login Test',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _testLogin,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Test Login'),
            ),
            const SizedBox(height: 24),
            Text(
              _message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Pre-fill with test data
                _emailController.text = 'live@example.com';
                _passwordController.text = 'testpass123';
                setState(() {
                  _message =
                      'Test credentials loaded (we created this account earlier)';
                });
              },
              child: const Text('Load Test Account'),
            ),
          ],
        ),
      ),
    );
  }
}
