// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/gaming_widgets.dart';
import '../../src/providers.dart';
import '../../src/translations.dart';
import '../menu.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _language = 'English';
  bool _notifications = true;
  bool _darkMode = true;
  bool _appSound = true;
  String _fontSize = 'Small';

  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final service = ref.read(userDataServiceProvider);
    final s = await service.getSettings();
    if (!mounted) return;
    setState(() {
      _language = (s['language'] ?? 'English').toString();
      _notifications = s['notifications'] as bool? ?? true;
      _darkMode = s['darkMode'] as bool? ?? true;
      _appSound = s['appSound'] as bool? ?? true;
      _fontSize = (s['fontSize'] ?? 'Small').toString();
      _loaded = true;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    final service = ref.read(userDataServiceProvider);
    final map = {
      'language': _language,
      'notifications': _notifications,
      'darkMode': _darkMode,
      'appSound': _appSound,
      'fontSize': _fontSize,
    };
    await service.saveSettings(map);
    // Apply immediately — font scale and notifications update without restart.
    ref.read(appSettingsProvider.notifier).update(AppSettings.fromMap(map));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('settings_saved'), style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700)),
        backgroundColor: kSteamGreen,
        duration: const Duration(seconds: 2),
      ),
    );
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
          tr('settings'),
          style: GoogleFonts.rajdhani(
            color: kSteamAccent, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 3,
          ),
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
          child: !_loaded
              ? const Center(child: CircularProgressIndicator(color: kSteamAccent))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SteamSectionHeader(tr('preferences')),
                      const SizedBox(height: 16),
                      _settingRow(
                        tr('language'),
                        _dropdown(_language, ['English', 'Spanish', 'French', 'German'],
                            (v) => setState(() => _language = v!)),
                      ),
                      _settingRow(
                        tr('notifications'),
                        _toggle(_notifications, (v) => setState(() => _notifications = v)),
                      ),
                      _settingRow(
                        tr('dark_mode'),
                        _toggle(_darkMode, (v) => setState(() => _darkMode = v)),
                      ),
                      _settingRow(
                        tr('app_sound'),
                        _toggle(_appSound, (v) => setState(() => _appSound = v)),
                      ),
                      _settingRow(
                        tr('font_size'),
                        _dropdown(_fontSize, ['Small', 'Medium', 'Large'],
                            (v) => setState(() => _fontSize = v!)),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: _saving
                            ? const Center(child: CircularProgressIndicator(color: kSteamAccent))
                            : GamingButton(label: tr('save_changes'), onPressed: _saveSettings),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _settingRow(String label, Widget control) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: kSteamDark,
          border: Border.all(color: kSteamMed, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 14, fontWeight: FontWeight.w600, color: kSteamText, letterSpacing: 0.3,
              ),
            ),
            control,
          ],
        ),
      ),
    );
  }

  Widget _toggle(bool value, ValueChanged<bool> onChanged) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: kSteamAccent,
      inactiveThumbColor: kSteamSubtext,
      inactiveTrackColor: kSteamMed,
    );
  }

  Widget _dropdown(String value, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: kSteamMed,
        border: Border.all(color: kSteamAccent.withValues(alpha: 0.4), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<String>(
        value: value,
        dropdownColor: kSteamDark,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: kSteamAccent, size: 20),
        items: options
            .map((v) => DropdownMenuItem(
                  value: v,
                  child: Text(
                    v,
                    style: GoogleFonts.rajdhani(
                      fontSize: 12, color: kSteamText, fontWeight: FontWeight.w600,
                    ),
                  ),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
