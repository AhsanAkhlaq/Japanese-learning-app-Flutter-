import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Sign in with Google'),
          onPressed: () async {
            final user = await authService.signInWithGoogle();
            if (user != null) {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Sign-in failed')));
            }
          },
        ),
      ),
    );
  }
}
