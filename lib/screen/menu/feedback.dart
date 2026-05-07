import 'package:flutter/material.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _feedbackController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GamingAppBar(title: 'FEEDBACK'),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 10,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RATE YOUR EXPERIENCE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_outline,
                          size: 32,
                          color: const Color(0xFF2563EB),
                        ),
                        onPressed: () => setState(() => _rating = index + 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'TELL US MORE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GamingTextField(
                    controller: _feedbackController,
                    hintText: 'YOUR FEEDBACK',
                    prefixIcon: Icons.edit,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(
                      label: 'SEND FEEDBACK',
                      onPressed: () {},
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
