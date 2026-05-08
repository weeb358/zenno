import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';
import 'package:zenno/src/providers.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _answerController = TextEditingController();
  String _selectedQuestion = "What is your pet's name?";

  final List<String> _securityQuestions = [
    "What is your pet's name?",
    "What is your mother's maiden name?",
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

    final auth = ref.read(authServiceProvider);
    try {
      final success = await auth.sendPasswordReset(_answerController.text.trim());
      if (!success) throw Exception('Reset failed');
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
      backgroundColor: kSteamBg,
      appBar: GamingAppBar(title: 'FORGOT PASSWORD'),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 8,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: kSteamDark,
                      border: Border.all(color: kSteamAccent, width: 3),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: kSteamAccent.withValues(alpha: 0.5), blurRadius: 28, spreadRadius: 2),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'ZENNO',
                        style: GoogleFonts.rajdhani(fontSize: 26, color: kSteamAccent, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'RECOVER YOUR ACCOUNT',
                    style: GoogleFonts.rajdhani(fontSize: 20, fontWeight: FontWeight.w800, color: kSteamText, letterSpacing: 2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Answer your security question to continue',
                    style: GoogleFonts.rajdhani(fontSize: 13, color: kSteamSubtext),
                  ),
                  const SizedBox(height: 36),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: kSteamDark,
                      border: Border.all(color: kSteamMed, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedQuestion,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: kSteamDark,
                      icon: const Icon(Icons.arrow_drop_down, color: kSteamAccent),
                      items: _securityQuestions.map((q) => DropdownMenuItem(
                        value: q,
                        child: Text(q, style: GoogleFonts.rajdhani(fontSize: 13, color: kSteamText)),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedQuestion = v ?? _securityQuestions[0]),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GamingTextField(
                    controller: _answerController,
                    hintText: 'SECURITY ANSWER',
                    prefixIcon: Icons.help_outline,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(label: 'CONTINUE', onPressed: _handleContinue),
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
