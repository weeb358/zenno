import 'package:flutter/material.dart';
import 'package:zenno/screen/auth/login.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin {
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
      begin: const Offset(0, 0.5),
      end: const Offset(0, -0.5),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const Authenticator();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(begin: const Offset(0, 1), end: Offset.zero);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return SlideTransition(
            position: tween.animate(curvedAnimation),
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
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 12,
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
                      // Center Logo
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Container(
                            width: 120,
                            height: 120,
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
                                  blurRadius: 30,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'ZENNO',
                                style: TextStyle(
                                  fontSize: 32,
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Animated arrow icon with swipe text
                      Expanded(
                        flex: 2,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border(
                                    top: BorderSide(color: Color(0xFF06B6D4), width: 3),
                                    bottom: BorderSide(color: Color(0xFF06B6D4), width: 3),
                                    left: BorderSide(color: Color(0xFF06B6D4), width: 3),
                                    right: BorderSide(color: Color(0xFF06B6D4), width: 3),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x9906B6D4),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_upward,
                                  size: 50,
                                  color: Color(0xFF06B6D4),
                                ),
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                'SWIPE UP TO LOGIN',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF06B6D4),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  // Open Account text on the left bottom
                  Positioned(
                    bottom: 40,
                    left: 24,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/signup');
                      },
                      child: Text(
                        'CREATE ACCOUNT',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
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


