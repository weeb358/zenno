import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';
import 'package:zenno/src/providers.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _answerController = TextEditingController();

  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  String _selectedQuestion = "What is your pet's name?";
  final List<String> _securityQuestions = [
    "What is your pet's name?",
    "What is your mother's maiden name?",
    'What city were you born in?',
    'What is your favorite color?',
  ];

  static const List<String> _countryList = [
    'Afghanistan', 'Albania', 'Algeria', 'Argentina', 'Armenia', 'Australia',
    'Austria', 'Azerbaijan', 'Bahrain', 'Bangladesh', 'Belarus', 'Belgium',
    'Bolivia', 'Bosnia and Herzegovina', 'Brazil', 'Bulgaria', 'Cambodia',
    'Canada', 'Chile', 'China', 'Colombia', 'Croatia', 'Cuba',
    'Czech Republic', 'Denmark', 'Ecuador', 'Egypt', 'Estonia', 'Ethiopia',
    'Finland', 'France', 'Georgia', 'Germany', 'Ghana', 'Greece', 'Guatemala',
    'Hungary', 'India', 'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Israel',
    'Italy', 'Japan', 'Jordan', 'Kazakhstan', 'Kenya', 'Kuwait', 'Latvia',
    'Lebanon', 'Libya', 'Lithuania', 'Malaysia', 'Mexico', 'Morocco',
    'Myanmar', 'Netherlands', 'New Zealand', 'Nigeria', 'North Korea',
    'Norway', 'Oman', 'Pakistan', 'Palestine', 'Peru', 'Philippines',
    'Poland', 'Portugal', 'Qatar', 'Romania', 'Russia', 'Saudi Arabia',
    'Serbia', 'Singapore', 'Slovakia', 'South Africa', 'South Korea',
    'Spain', 'Sri Lanka', 'Sudan', 'Sweden', 'Switzerland', 'Syria',
    'Taiwan', 'Tanzania', 'Thailand', 'Tunisia', 'Turkey', 'UAE', 'Ukraine',
    'United Kingdom', 'United States', 'Uruguay', 'Venezuela', 'Vietnam',
    'Yemen', 'Zimbabwe',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    String search = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSteamDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final filtered = _countryList
              .where((c) => c.toLowerCase().contains(search.toLowerCase()))
              .toList();
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.75,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: kSteamMed, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'SELECT COUNTRY',
                    style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 2),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      autofocus: true,
                      style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search country...',
                        hintStyle: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: kSteamAccent, size: 20),
                        filled: true,
                        fillColor: kSteamBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: kSteamMed),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: kSteamAccent),
                        ),
                      ),
                      onChanged: (v) => setSheet(() => search = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.flag_outlined, color: kSteamAccent, size: 18),
                        title: Text(filtered[i], style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 14)),
                        onTap: () {
                          setState(() => _countryController.text = filtered[i]);
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final firebaseReady = ref.read(firebaseReadyProvider);
    if (!firebaseReady) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firebase not configured. Running offline.')),
      );
      context.go('/login');
      setState(() => _isLoading = false);
      return;
    }

    final auth = ref.read(authServiceProvider);
    try {
      await auth.signUpWithUsernameEmail(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        country: _countryController.text.trim(),
        password: _passwordController.text,
        securityQuestion: _selectedQuestion,
        securityAnswer: _answerController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Please sign in.')),
      );
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    bool? passwordVisible,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !(passwordVisible ?? false),
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
        prefixIcon: Icon(icon, color: kSteamAccent, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  (passwordVisible ?? false) ? Icons.visibility_off : Icons.visibility,
                  color: kSteamSubtext,
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              )
            : suffixIcon,
        filled: true,
        fillColor: kSteamDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: kSteamMed, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: kSteamAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: kSteamRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: kSteamRed, width: 1.5),
        ),
        errorStyle: GoogleFonts.rajdhani(color: kSteamRed, fontSize: 11),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: AppBar(
        backgroundColor: kSteamDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kSteamAccent),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'CREATE ACCOUNT',
          style: GoogleFonts.rajdhani(color: kSteamAccent, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 3),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, kSteamAccent, Colors.transparent]),
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Logo
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: kSteamDark,
                        border: Border.all(color: kSteamAccent, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.4), blurRadius: 24)],
                      ),
                      child: Center(
                        child: Text(
                          'ZENNO',
                          style: GoogleFonts.rajdhani(fontSize: 18, color: kSteamAccent, fontWeight: FontWeight.w800, letterSpacing: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('JOIN ZENNO', style: GoogleFonts.rajdhani(fontSize: 24, fontWeight: FontWeight.w800, color: kSteamText, letterSpacing: 3)),
                    const SizedBox(height: 4),
                    Text('Create your gaming account', style: GoogleFonts.rajdhani(fontSize: 13, color: kSteamSubtext)),
                    const SizedBox(height: 28),

                    // Username
                    _buildField(
                      controller: _usernameController,
                      hint: 'USERNAME',
                      icon: Icons.person,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Username is required' : null,
                    ),
                    const SizedBox(height: 14),

                    // Email
                    _buildField(
                      controller: _emailController,
                      hint: 'EMAIL',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Country — tappable picker
                    _buildField(
                      controller: _countryController,
                      hint: 'SELECT COUNTRY',
                      icon: Icons.public,
                      readOnly: true,
                      onTap: _showCountryPicker,
                      suffixIcon: const Icon(Icons.arrow_drop_down, color: kSteamAccent),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Country is required' : null,
                    ),
                    const SizedBox(height: 14),

                    // Password
                    _buildField(
                      controller: _passwordController,
                      hint: 'PASSWORD',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      passwordVisible: _passwordVisible,
                      onToggleVisibility: () => setState(() => _passwordVisible = !_passwordVisible),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        if (v.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Confirm Password
                    _buildField(
                      controller: _confirmPasswordController,
                      hint: 'CONFIRM PASSWORD',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      passwordVisible: _confirmPasswordVisible,
                      onToggleVisibility: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please confirm your password';
                        if (v != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Security question
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: kSteamDark,
                        border: Border.all(color: kSteamMed, width: 1.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined, color: kSteamAccent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Security answer
                    _buildField(
                      controller: _answerController,
                      hint: 'SECURITY ANSWER',
                      icon: Icons.help_outline,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Security answer is required' : null,
                    ),
                    const SizedBox(height: 32),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: kSteamAccent))
                          : ElevatedButton(
                              onPressed: _handleSignup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kSteamAccent,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                elevation: 0,
                              ),
                              child: Text(
                                'CREATE ACCOUNT',
                                style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 2),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                            ),
                            TextSpan(
                              text: 'SIGN IN',
                              style: GoogleFonts.rajdhani(
                                color: kSteamAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                decoration: TextDecoration.underline,
                                decorationColor: kSteamAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
