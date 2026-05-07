import 'package:flutter/material.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GamingAppBar(title: 'SETTINGS'),
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
                    'NOTIFICATION SETTINGS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2563EB), width: 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Enable Notifications',
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                        Switch(
                          value: _notificationsEnabled,
                          onChanged: (val) => setState(() => _notificationsEnabled = val),
                          activeThumbColor: const Color(0xFF2563EB),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2563EB), width: 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sound Effects',
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                        Switch(
                          value: _soundEnabled,
                          onChanged: (val) => setState(() => _soundEnabled = val),
                          activeThumbColor: const Color(0xFF06B6D4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2563EB), width: 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Vibration',
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                        Switch(
                          value: _vibrationEnabled,
                          onChanged: (val) => setState(() => _vibrationEnabled = val),
                          activeThumbColor: const Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'ACCOUNT SETTINGS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(
                      label: 'CHANGE PASSWORD',
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(
                      label: 'LOGOUT',
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
