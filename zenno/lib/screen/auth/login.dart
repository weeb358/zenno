import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';
import 'package:zenno/src/providers.dart';

class Authenticator extends ConsumerStatefulWidget {
  const Authenticator({super.key});

  @override
  ConsumerState<Authenticator> createState() => _AuthenticatorState();
}

class _AuthenticatorState extends ConsumerState<Authenticator> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your username/email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authServiceProvider);
      final credential = await auth.signInWithUsernameOrEmail(username, password);

      if (!mounted) return;

      final userEmail = credential?.user?.email ?? '';
      ref.read(localAuthSessionProvider.notifier).state = null;
      context.go(userEmail == adminEmail ? '/admin-dashboard' : '/home');
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceAll('Exception: ', '');
      if (message == 'blocked_by_admin') {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: kSteamDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: kSteamRed, width: 1.5),
            ),
            title: Row(
              children: [
                const Icon(Icons.block, color: kSteamRed, size: 22),
                const SizedBox(width: 10),
                Text('Account Blocked', style: GoogleFonts.rajdhani(color: kSteamRed, fontWeight: FontWeight.w800, fontSize: 18)),
              ],
            ),
            content: Text(
              'You have been blocked by the admin.\nPlease contact the admin to resolve this issue.',
              style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 14, height: 1.6),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: GoogleFonts.rajdhani(color: kSteamAccent, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSteamBg,
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 8,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: kSteamDark,
                      border: Border.all(color: kSteamAccent, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: kSteamAccent.withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'ZENNO',
                        style: GoogleFonts.rajdhani(
                          fontSize: 22,
                          color: kSteamAccent,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'WELCOME BACK',
                    style: GoogleFonts.rajdhani(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: kSteamText,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to your account',
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: kSteamSubtext,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 36),
                  GamingTextField(
                    controller: _usernameController,
                    hintText: 'EMAIL',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  GamingTextField(
                    controller: _passwordController,
                    hintText: 'PASSWORD',
                    isPassword: true,
                    prefixIcon: Icons.lock,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/signup'),
                        child: Text(
                          'CREATE ACCOUNT',
                          style: GoogleFonts.rajdhani(
                            color: kSteamGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: kSteamGreen,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/forgot-password'),
                        child: Text(
                          'FORGOT PASSWORD',
                          style: GoogleFonts.rajdhani(
                            color: kSteamSubtext,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: kSteamSubtext,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: kSteamAccent))
                        : GamingButton(label: 'SIGN IN', onPressed: _handleLogin),
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
