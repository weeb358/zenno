import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';
import 'package:zenno/src/providers.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final firebaseReady = ref.read(firebaseReadyProvider);
    if (!firebaseReady) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firebase not configured. Password updated locally.')),
      );
      context.go('/login');
      return;
    }

    final auth = ref.read(authServiceProvider);
    try {
      final success = await auth.changePassword(_newPasswordController.text);
      if (!success) throw Exception('Change password failed');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully')));
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Change failed: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: GamingAppBar(title: 'RESET PASSWORD'),
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
                    'SET NEW PASSWORD',
                    style: GoogleFonts.rajdhani(fontSize: 20, fontWeight: FontWeight.w800, color: kSteamText, letterSpacing: 2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose a strong password',
                    style: GoogleFonts.rajdhani(fontSize: 13, color: kSteamSubtext),
                  ),
                  const SizedBox(height: 36),
                  GamingTextField(
                    controller: _newPasswordController,
                    hintText: 'NEW PASSWORD',
                    prefixIcon: Icons.lock,
                    isPassword: true,
                  ),
                  const SizedBox(height: 14),
                  GamingTextField(
                    controller: _confirmPasswordController,
                    hintText: 'CONFIRM PASSWORD',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(label: 'CONFIRM', onPressed: _handleConfirm),
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
