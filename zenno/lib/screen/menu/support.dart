import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _subjectController = TextEditingController();
  final _issueController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _issueController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
  );

  Widget _darkField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: kSteamDark,
        border: Border.all(color: kSteamMed, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: GamingAppBar(title: 'SUPPORT'),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 8,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SteamSectionHeader('Get Help'),
                  const SizedBox(height: 6),
                  Text('How can we help you?', style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13)),
                  const SizedBox(height: 20),
                  _fieldLabel('SUBJECT'),
                  _darkField(_subjectController, 'Enter subject'),
                  const SizedBox(height: 14),
                  _fieldLabel('DESCRIBE YOUR ISSUE'),
                  _darkField(_issueController, 'Describe your issue in detail', maxLines: 5),
                  const SizedBox(height: 14),
                  _fieldLabel('EMAIL'),
                  _darkField(_emailController, 'Enter your email'),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(
                      label: 'Submit Request',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Support request submitted!')),
                        );
                        _subjectController.clear();
                        _issueController.clear();
                        _emailController.clear();
                      },
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
