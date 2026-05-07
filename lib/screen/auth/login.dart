import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenno/widgets/gaming_widgets.dart';
import 'package:zenno/src/providers.dart';

// Preserve UI exactly; hook auth calls via Riverpod

class Authenticator extends ConsumerStatefulWidget {
  const Authenticator({super.key});

  @override
  ConsumerState<Authenticator> createState() => _AuthenticatorState();
}

class _AuthenticatorState extends ConsumerState<Authenticator> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final firebaseReady = ref.read(firebaseReadyProvider);
    if (!firebaseReady) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firebase is not configured. Running in offline mode.')),
      );
      context.go('/home');
      return;
    }

    final auth = ref.read(authServiceProvider);
    try {
      var username = _usernameController.text.trim();
      // Allow shorthand 'admin' to map to the admin email used by the app
      if (username == 'admin') username = 'admin@zenno.com';
      final success = await auth.signInWithEmail(username, _passwordController.text);
      if (!success) {
        throw Exception('Invalid credentials');
      }
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GamingAppBar(
        title: 'Login',
      ),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 8,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Logo with glow
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFF2563EB),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x992563EB),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'ZENNO',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Welcome text
                  Text(
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
                        child: Text(
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
                        child: Text(
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
      ),
    );
  }
}
