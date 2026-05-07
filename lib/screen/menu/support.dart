import 'package:flutter/material.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GamingAppBar(title: 'SUPPORT'),
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
                    'HOW CAN WE HELP?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2563EB), width: 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Common Issues:\n• Payment problems\n• Download issues\n• Account access\n• Technical support',
                      style: TextStyle(fontSize: 12, color: Colors.white, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'CONTACT US',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GamingTextField(
                    controller: _messageController,
                    hintText: 'DESCRIBE YOUR ISSUE',
                    prefixIcon: Icons.message,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(
                      label: 'SUBMIT TICKET',
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
