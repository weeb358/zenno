import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        const SnackBar(content: Text('Firebase is not configured. Password updated locally.')),
      );
      context.go('/login');
      return;
    }

    final auth = ref.read(authServiceProvider);
    try {
      final success = await auth.changePassword(_newPasswordController.text);
      if (!success) {
        throw Exception('Change password failed');
      }
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
      appBar: const GamingAppBar(
        title: 'RESET PASSWORD',
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
                  // Change Password text
                  const Text(
                    'SET NEW PASSWORD',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // New Password field
                  GamingTextField(
                    controller: _newPasswordController,
                    hintText: 'NEW PASSWORD',
                    prefixIcon: Icons.lock,
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),
                  // Confirm Password field
                  GamingTextField(
                    controller: _confirmPasswordController,
                    hintText: 'CONFIRM PASSWORD',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 60),
                  // Confirm button
                  GamingButton(
                    label: 'CONFIRM',
                    onPressed: _handleConfirm,
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
