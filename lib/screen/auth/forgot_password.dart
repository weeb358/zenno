import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenno/widgets/gaming_widgets.dart';
import 'package:zenno/src/providers.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
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
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer the security question')),
      );
      return;
    }

    final firebaseReady = ref.read(firebaseReadyProvider);
    if (!firebaseReady) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firebase is not configured. Offline recovery mode.')),
      );
      context.push('/change-password');
      return;
    }

    // For demo: treat the answer field as email for reset
    final auth = ref.read(authServiceProvider);
    try {
      final success = await auth.sendPasswordReset(_answerController.text.trim());
      if (!success) {
        throw Exception('Reset failed');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent')));
      context.push('/change-password');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reset failed: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GamingAppBar(
        title: 'FORGOT PASSWORD',
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
                  // Glowing Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFF2563EB), width: 3),
                        bottom: BorderSide(color: Color(0xFF2563EB), width: 3),
                        left: BorderSide(color: Color(0xFF2563EB), width: 3),
                        right: BorderSide(color: Color(0xFF2563EB), width: 3),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xCC2563EB),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
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
                  // Forgot Password text
                  const Text(
                    'RECOVER YOUR ACCOUNT',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
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
                  const SizedBox(height: 20),
                  // Answer field
                  GamingTextField(
                    controller: _answerController,
                    hintText: 'SECURITY ANSWER',
                    prefixIcon: Icons.help,
                  ),
                  const SizedBox(height: 60),
                  // Continue button
                  GamingButton(
                    label: 'CONTINUE',
                    onPressed: _handleContinue,
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
