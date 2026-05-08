import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';
import 'homescreen.dart';

class CheckoutSuccessScreen extends StatelessWidget {
  final String gameName;

  const CheckoutSuccessScreen({super.key, required this.gameName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSteamBg,
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 12,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success icon with glow
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kSteamGreen.withValues(alpha: 0.15),
                        border: Border.all(color: kSteamGreen, width: 2),
                        boxShadow: [
                          BoxShadow(color: kSteamGreen.withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 2),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.check_circle_outline, color: kSteamGreen, size: 52),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      "PURCHASE COMPLETE!",
                      style: GoogleFonts.rajdhani(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: kSteamText,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: kSteamDark,
                        border: Border.all(color: kSteamGreen.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        gameName,
                        style: GoogleFonts.rajdhani(color: kSteamGreen, fontWeight: FontWeight.w700, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your payment was processed successfully.\nEnjoy your game!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(fontSize: 14, color: kSteamSubtext, height: 1.6),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      child: GamingButton(
                        label: 'Browse More Games',
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const Homescreen()),
                        ),
                        color: kSteamAccent,
                      ),
                    ),
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
