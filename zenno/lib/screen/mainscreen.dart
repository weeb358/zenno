import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/screen/auth/login.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: const Offset(0, -0.3),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const Authenticator(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(begin: const Offset(0, 1), end: Offset.zero);
          return SlideTransition(
            position: tween.animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSteamBg,
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 16,
          child: SafeArea(
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.velocity.pixelsPerSecond.dy < -500) {
                  _navigateToLogin();
                }
              },
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: kSteamDark,
                              border: Border.all(color: kSteamAccent, width: 3),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(color: kSteamAccent.withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 4),
                                BoxShadow(color: kSteamGreen.withValues(alpha: 0.2), blurRadius: 60, spreadRadius: 8),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'ZENNO',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 36,
                                  color: kSteamAccent,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                  shadows: [Shadow(color: kSteamAccent.withValues(alpha: 0.8), blurRadius: 20)],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: kSteamAccent, width: 2),
                                  boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.4), blurRadius: 20)],
                                ),
                                child: const Icon(Icons.arrow_upward, size: 40, color: kSteamAccent),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'SWIPE UP TO LOGIN',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 15,
                                  color: kSteamAccent,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  Positioned(
                    bottom: 40,
                    left: 24,
                    child: GestureDetector(
                      onTap: () => context.push('/signup'),
                      child: Text(
                        'CREATE ACCOUNT',
                        style: GoogleFonts.rajdhani(
                          fontSize: 15,
                          color: kSteamGreen,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: kSteamGreen,
                          letterSpacing: 1.5,
                        ),
                      ),
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
