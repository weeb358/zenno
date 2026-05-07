import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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

  void _handleSignup() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GamingAppBar(
        title: 'Create Account',
        showThemeButton: false,
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
                Container(
                  width: 80,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFF2563EB),
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x7F2563EB),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'ZENNO',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Create Account text
                Text(
                  'CREATE ACCOUNT',
                  style: TextStyle(
                    fontSize: 22,
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
                  isPassword: true,
                  prefixIcon: Icons.lock,
                ),
                const SizedBox(height: 16),
                // Security Question dropdown
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0x802563EB),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x332563EB),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: DropdownButton<String>(
                    value: _selectedQuestion,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: Color(0xFFFAFAFA),
                    items: _securityQuestions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            value,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w500,
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
                  ),
                ),
                const SizedBox(height: 16),
                // Answer field
                GamingTextField(
                  controller: _answerController,
                  hintText: 'ANSWER',
                  prefixIcon: Icons.help,
                ),
                const SizedBox(height: 40),
                // Sign up button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: GamingButton(
                    label: 'SIGN UP',
                    onPressed: _handleSignup,
                    isPrimary: true,
                  ),
                ),
                const SizedBox(height: 16),
                // Link to login
                GestureDetector(
                  onTap: () {
                    context.go('/login');
                  },
                  child: Text(
                    'Already a member? LOGIN NOW',
                    style: TextStyle(
                      color: Color(0xFF06B6D4),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      letterSpacing: 0.5,
                    ),
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
