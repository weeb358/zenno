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
  // 0 = email, 1 = security Q&A, 2 = new password, 3 = success
  int _step = 0;
  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final _emailController = TextEditingController();
  final _answerController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _securityQuestion = '';
  String _verifiedEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _answerController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Step 0: find account by email ────────────────────────────────────────
  Future<void> _findAccount() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) { _snack('Please enter your email address'); return; }
    if (!email.contains('@')) { _snack('Please enter a valid email address'); return; }

    setState(() => _loading = true);
    try {
      final firebaseReady = ref.read(firebaseReadyProvider);
      if (!firebaseReady) { _snack('Firebase is not configured'); return; }

      final auth = ref.read(authServiceProvider);
      final question = await auth.getSecurityQuestionByEmail(email);
      if (!mounted) return;
      if (question == null || question.isEmpty) {
        _snack('No account found with that email address');
        return;
      }
      setState(() {
        _securityQuestion = question;
        _verifiedEmail = email;
        _answerController.clear();
        _step = 1;
      });
    } catch (e) {
      if (mounted) _snack('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Step 1: verify security answer ───────────────────────────────────────
  Future<void> _verifyAnswer() async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) { _snack('Please enter your security answer'); return; }

    setState(() => _loading = true);
    try {
      final auth = ref.read(authServiceProvider);
      final correct = await auth.verifySecurityAnswer(_verifiedEmail, answer);
      if (!mounted) return;
      if (!correct) {
        _snack('Incorrect answer. Please try again.');
        return;
      }
      setState(() {
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _step = 2;
      });
    } catch (e) {
      if (mounted) _snack('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Step 2: set new password ──────────────────────────────────────────────
  Future<void> _setNewPassword() async {
    final pw = _newPasswordController.text.trim();
    final cpw = _confirmPasswordController.text.trim();
    if (pw.isEmpty || cpw.isEmpty) { _snack('Please fill in both fields'); return; }
    if (pw.length < 6) { _snack('Password must be at least 6 characters'); return; }
    if (pw != cpw) { _snack('Passwords do not match'); return; }

    setState(() => _loading = true);
    try {
      final auth = ref.read(authServiceProvider);
      await auth.resetUserPassword(_verifiedEmail, pw);
      if (!mounted) return;
      setState(() => _step = 3);
    } catch (e) {
      if (mounted) _snack('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ── AppBar back behaviour ─────────────────────────────────────────────────
  Widget? _leading() {
    if (_step == 3) return const SizedBox();
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: kSteamAccent),
      onPressed: () {
        if (_step == 0) {
          context.pop();
        } else {
          setState(() => _step -= 1);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: AppBar(
        backgroundColor: kSteamDark,
        elevation: 0,
        leading: _leading(),
        title: Text(
          'FORGOT PASSWORD',
          style: GoogleFonts.rajdhani(
            color: kSteamAccent,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, kSteamAccent, Colors.transparent],
              ),
            ),
          ),
        ),
      ),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 8,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // Logo
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: kSteamDark,
                      border: Border.all(color: kSteamAccent, width: 3),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: kSteamAccent.withValues(alpha: 0.5),
                          blurRadius: 28,
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
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Step indicator (hidden on success)
                  if (_step < 3) _buildStepIndicator(),
                  const SizedBox(height: 28),

                  // Step content
                  if (_step == 0) _buildStepEmail(),
                  if (_step == 1) _buildStepAnswer(),
                  if (_step == 2) _buildStepNewPassword(),
                  if (_step == 3) _buildStepSuccess(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Step indicator ────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepDot(0),
        _stepLine(0),
        _stepDot(1),
        _stepLine(1),
        _stepDot(2),
      ],
    );
  }

  Widget _stepDot(int index) {
    final active = _step >= index;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: active ? kSteamAccent : kSteamMed,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: GoogleFonts.rajdhani(
            color: active ? kSteamDark : kSteamSubtext,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _stepLine(int afterStep) => Container(
        width: 36,
        height: 2,
        color: _step > afterStep ? kSteamAccent : kSteamMed,
      );

  // ── Email field ───────────────────────────────────────────────────────────
  Widget _buildStepEmail() {
    return Column(
      children: [
        Text(
          'FIND YOUR ACCOUNT',
          style: GoogleFonts.rajdhani(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: kSteamText,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter your registered email address',
          style: GoogleFonts.rajdhani(fontSize: 13, color: kSteamSubtext),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        GamingTextField(
          controller: _emailController,
          hintText: 'EMAIL ADDRESS',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: kSteamAccent))
              : GamingButton(label: 'FIND ACCOUNT', onPressed: _findAccount),
        ),
      ],
    );
  }

  // ── Security Q&A ──────────────────────────────────────────────────────────
  Widget _buildStepAnswer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'SECURITY VERIFICATION',
            style: GoogleFonts.rajdhani(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kSteamText,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Answer the question you set during sign up',
            style: GoogleFonts.rajdhani(fontSize: 13, color: kSteamSubtext),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        _emailBadge(),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kSteamDark,
            border: Border.all(color: kSteamAccent.withValues(alpha: 0.5), width: 1.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SECURITY QUESTION',
                style: GoogleFonts.rajdhani(
                  color: kSteamAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _securityQuestion,
                style: GoogleFonts.rajdhani(
                  color: kSteamText,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GamingTextField(
          controller: _answerController,
          hintText: 'YOUR ANSWER',
          prefixIcon: Icons.help_outline,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: kSteamAccent))
              : GamingButton(label: 'VERIFY', onPressed: _verifyAnswer),
        ),
      ],
    );
  }

  // ── New password form ─────────────────────────────────────────────────────
  Widget _buildStepNewPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'SET NEW PASSWORD',
            style: GoogleFonts.rajdhani(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kSteamText,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Create a strong new password for your account',
            style: GoogleFonts.rajdhani(fontSize: 13, color: kSteamSubtext),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        _emailBadge(),
        const SizedBox(height: 20),

        // New password
        _passwordField(
          controller: _newPasswordController,
          hint: 'NEW PASSWORD',
          icon: Icons.lock_outline,
          obscure: _obscureNew,
          onToggle: () => setState(() => _obscureNew = !_obscureNew),
        ),
        const SizedBox(height: 14),

        // Confirm password
        _passwordField(
          controller: _confirmPasswordController,
          hint: 'CONFIRM PASSWORD',
          icon: Icons.lock,
          obscure: _obscureConfirm,
          onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
        const SizedBox(height: 6),
        Text(
          'Minimum 6 characters',
          style: GoogleFonts.rajdhani(fontSize: 11, color: kSteamSubtext),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: kSteamAccent))
              : GamingButton(label: 'UPDATE PASSWORD', onPressed: _setNewPassword),
        ),
      ],
    );
  }

  // ── Success ───────────────────────────────────────────────────────────────
  Widget _buildStepSuccess() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: kSteamGreen.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: kSteamGreen, width: 2),
          ),
          child: const Icon(Icons.check_circle_outline, color: kSteamGreen, size: 44),
        ),
        const SizedBox(height: 24),
        Text(
          'PASSWORD UPDATED!',
          style: GoogleFonts.rajdhani(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: kSteamGreen,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Password updated for',
          style: GoogleFonts.rajdhani(fontSize: 13, color: kSteamSubtext),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          _verifiedEmail,
          style: GoogleFonts.rajdhani(
            fontSize: 14,
            color: kSteamAccent,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'You can now log in with your new password.',
          style: GoogleFonts.rajdhani(fontSize: 13, color: kSteamSubtext),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: GamingButton(
            label: 'BACK TO LOGIN',
            onPressed: () => context.go('/login'),
          ),
        ),
      ],
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────────
  Widget _emailBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kSteamMed,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kSteamAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: kSteamGreen, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _verifiedEmail,
              style: GoogleFonts.rajdhani(
                color: kSteamText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kSteamDark,
        border: Border.all(color: kSteamMed, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
          prefixIcon: Icon(icon, color: kSteamAccent, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: kSteamSubtext,
              size: 20,
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
