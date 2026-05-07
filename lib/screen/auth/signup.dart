import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenno/widgets/gaming_widgets.dart';
import 'package:zenno/src/providers.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryController = TextEditingController();
  final _passwordController = TextEditingController();
  final _answerController = TextEditingController();
  
  String _selectedQuestion = 'What is your pet\'s name?';

  final List<String> _securityQuestions = [
    'What is your pet\'s name?',
    'What is your mother\'s maiden name?',
    'What city were you born in?',
    'What is your favorite color?',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _passwordController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final firebaseReady = ref.read(firebaseReadyProvider);
    if (!firebaseReady) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firebase is not configured. Running in offline mode.')),
      );
      context.go('/login');
      return;
    }

    final auth = ref.read(authServiceProvider);
    try {
      final success = await auth.signUpWithEmail(_emailController.text.trim(), _passwordController.text);
      if (!success) {
        throw Exception('Signup failed');
      }
      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signup failed: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GamingAppBar(
        title: 'CREATE ACCOUNT',
      ),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 10,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Glowing Logo
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
                          color: Color(0xCC2563EB),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'ZENNO',
                        style: TextStyle(
                          fontSize: 28,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Create Account text
                  Text(
                    'CREATE YOUR ACCOUNT',
                    style: TextStyle(
                      fontSize: 20,
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
                  const SizedBox(height: 16),
                  // Email field
                  GamingTextField(
                    controller: _emailController,
                    hintText: 'EMAIL',
                    prefixIcon: Icons.email,
                  ),
                  const SizedBox(height: 16),
                  // Country field
                  GamingTextField(
                    controller: _countryController,
                    hintText: 'COUNTRY',
                    prefixIcon: Icons.public,
                  ),
                  const SizedBox(height: 16),
                  // Password field
                  GamingTextField(
                    controller: _passwordController,
                    hintText: 'PASSWORD',
                    prefixIcon: Icons.lock,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  // Security Question dropdown
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFF2563EB),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x4D2563EB),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: DropdownButton<String>(
                      value: _selectedQuestion,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _securityQuestions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedQuestion = newValue ?? _securityQuestions[0];
                        });
                      },
                      dropdownColor: Color(0xFFFAFAFA),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Answer field
                  GamingTextField(
                    controller: _answerController,
                    hintText: 'SECURITY ANSWER',
                    prefixIcon: Icons.help,
                  ),
                  const SizedBox(height: 40),
                  // Sign up button
                  GamingButton(
                    label: 'SIGN UP',
                    onPressed: _handleSignup,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
