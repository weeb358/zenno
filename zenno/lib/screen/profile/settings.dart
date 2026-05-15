import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  Widget _settingToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: kSteamDark,
          border: Border.all(color: kSteamMed, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.rajdhani(fontSize: 14, color: kSteamText, fontWeight: FontWeight.w600)),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: kSteamAccent,
              inactiveThumbColor: kSteamSubtext,
              inactiveTrackColor: kSteamMed,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: GamingAppBar(title: 'SETTINGS'),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 8,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SteamSectionHeader('Notification Settings'),
                  const SizedBox(height: 12),
                  _settingToggle('Enable Notifications', _notificationsEnabled, (v) => setState(() => _notificationsEnabled = v)),
                  _settingToggle('Sound Effects', _soundEnabled, (v) => setState(() => _soundEnabled = v)),
                  _settingToggle('Vibration', _vibrationEnabled, (v) => setState(() => _vibrationEnabled = v)),
                  const SizedBox(height: 20),
                  const SteamSectionHeader('Account Settings'),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(
                      label: 'CHANGE PASSWORD',
                      onPressed: () => context.push('/change-password'),
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
