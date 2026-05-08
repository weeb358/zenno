import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class Authenticator extends StatefulWidget {
  const Authenticator({super.key});

  @override
  State<Authenticator> createState() => _AuthenticatorState();
}

class _AuthenticatorState extends State<Authenticator> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GamingAppBar(
        title: 'Login',
      ),
      body: GamingGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Logo with glow
                const SizedBox(),
                const SizedBox(height: 50),
                // Welcome text
                const Text(
                  'WELCOME GAMER',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 30),
                // Username field
                GamingTextField(
                  controller: _usernameController,
                  hintText: 'USERNAME',
                  prefixIcon: Icons.person,
                ),
                const SizedBox(height: 20),
                // Password field
                GamingTextField(
                  controller: _passwordController,
                  hintText: 'PASSWORD',
                  isPassword: true,
                  prefixIcon: Icons.lock,
                ),
                const SizedBox(height: 25),
                // Sign up and Forgot password links
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.push('/signup');
                      },
                      child: const Text(
                        'SIGN UP',
                        style: TextStyle(
                          color: Color(0xFF06B6D4),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push('/forgot-password');
                      },
                      child: const Text(
                        'FORGOT PASSWORD',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: GamingButton(
                    label: 'LOGIN',
                    onPressed: _handleLogin,
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
