import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/gaming_widgets.dart';
import '../menu.dart';
import '../chat/chatbot.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _feedbackController = TextEditingController();
  int _selectedRating = 0;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
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
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MenuScreen()),
          ),
        ),
        title: Text(
          'FEEDBACK',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SteamSectionHeader('Share Your Thoughts'),
                const SizedBox(height: 6),
                Text(
                  'Tell us what you think',
                  style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                ),
                const SizedBox(height: 24),
                Text(
                  'RATE YOUR EXPERIENCE',
                  style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final filled = _selectedRating >= index + 1;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedRating = index + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          filled ? Icons.star : Icons.star_border,
                          color: filled ? kSteamAccent : kSteamSubtext,
                          size: 34,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Text(
                  'YOUR FEEDBACK',
                  style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: kSteamDark,
                    border: Border.all(color: kSteamMed, width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: _feedbackController,
                    maxLines: 5,
                    style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Share your feedback with us',
                      hintStyle: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: GamingButton(
                    label: 'Submit Feedback',
                    onPressed: () {
                      if (_selectedRating == 0 || _feedbackController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please rate and provide feedback')),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thank you for your feedback!')),
                      );
                      _feedbackController.clear();
                      setState(() => _selectedRating = 0);
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: kSteamDark, border: Border(top: BorderSide(color: kSteamMed, width: 1))),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen())),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: kSteamMed,
                      shape: BoxShape.circle,
                      border: Border.all(color: kSteamAccent.withValues(alpha: 0.6)),
                      boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.2), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.smart_toy, color: kSteamAccent, size: 22),
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
