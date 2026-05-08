import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1600), vsync: this);
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSteamBg,
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 16,
          child: Center(
            child: ScaleTransition(
              scale: _scale,
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glowing logo
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: kSteamDark,
                        border: Border.all(color: kSteamAccent, width: 3),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: kSteamAccent.withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 4),
                          BoxShadow(color: kSteamGreen.withValues(alpha: 0.2), blurRadius: 60, spreadRadius: 8),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'ZENNO',
                          style: GoogleFonts.rajdhani(
                            fontSize: 46,
                            color: kSteamAccent,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            shadows: [Shadow(color: kSteamAccent.withValues(alpha: 0.8), blurRadius: 20)],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'YOUR GAMING HUB',
                      style: GoogleFonts.rajdhani(
                        fontSize: 16,
                        color: kSteamSubtext,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'LEVEL UP YOUR GAME',
                      style: GoogleFonts.rajdhani(
                        fontSize: 13,
                        color: kSteamGreen,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        backgroundColor: kSteamMed,
                        valueColor: const AlwaysStoppedAnimation<Color>(kSteamAccent),
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
