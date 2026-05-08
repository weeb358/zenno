import 'package:flutter/material.dart';
import '../widgets/gaming_widgets.dart';
import 'homescreen.dart';

class CheckoutSuccessScreen extends StatefulWidget {
  final String gameName;

  const CheckoutSuccessScreen({
    super.key,
    required this.gameName,
  });

  @override
  State<CheckoutSuccessScreen> createState() => _CheckoutSuccessScreenState();
}

class _CheckoutSuccessScreenState extends State<CheckoutSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: GamingGradientBackground(
        child: ParticleWidget(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2563EB),
                          width: 2,
                        ),
                        color: const Color(0xFFDEF7FA),
                      ),
                      child: const Center(
                        child: Text(
                          '🎉',
                          style: TextStyle(
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Success Heading
                    const Text(
                      'You\'re All Set!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Success Message
                    const Text(
                      'Thanks! Your payment was\nprocessed successfully.\nReady for more fun!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2563EB),
                        letterSpacing: 0.3,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Browse More Games Button
                    SizedBox(
                      width: 180,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const Homescreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF2563EB),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            color: const Color(0xFFFAFAFA),
                          ),
                          child: const Center(
                            child: Text(
                              'BROWSE MORE GAMES',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
                                letterSpacing: 0.5,
                              ),
                            ),
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
      ),
    );
  }
}
