import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/gaming_widgets.dart';
import '../menu.dart';
import '../chat/chatbot.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _appSoundEnabled = true;
  String _selectedFontSize = 'Small';

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
            Text(label, style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.w600, color: kSteamText, letterSpacing: 0.3)),
            control,
          ],
        ),
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
          'SETTINGS',
          style: GoogleFonts.rajdhani(color: kSteamAccent, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 3),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SteamSectionHeader('Preferences'),
                const SizedBox(height: 16),
                _settingRow(
                  'Language',
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: kSteamMed,
                      border: Border.all(color: kSteamAccent.withValues(alpha: 0.4), width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      dropdownColor: kSteamDark,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, color: kSteamAccent, size: 20),
                      items: ['English', 'Spanish', 'French', 'German'].map((v) => DropdownMenuItem(
                        value: v,
                        child: Text(v, style: GoogleFonts.rajdhani(fontSize: 12, color: kSteamText, fontWeight: FontWeight.w600)),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedLanguage = v!),
                    ),
                  ),
                ),
                _settingRow(
                  'Notifications',
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: (v) => setState(() => _notificationsEnabled = v),
                    activeThumbColor: kSteamAccent,
                    inactiveThumbColor: kSteamSubtext,
                    inactiveTrackColor: kSteamMed,
                  ),
                ),
                _settingRow(
                  'Dark Mode',
                  Switch(
                    value: _darkModeEnabled,
                    onChanged: (v) => setState(() => _darkModeEnabled = v),
                    activeThumbColor: kSteamAccent,
                    inactiveThumbColor: kSteamSubtext,
                    inactiveTrackColor: kSteamMed,
                  ),
                ),
                _settingRow(
                  'App Sound',
                  Switch(
                    value: _appSoundEnabled,
                    onChanged: (v) => setState(() => _appSoundEnabled = v),
                    activeThumbColor: kSteamAccent,
                    inactiveThumbColor: kSteamSubtext,
                    inactiveTrackColor: kSteamMed,
                  ),
                ),
                _settingRow(
                  'Font Size',
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: kSteamMed,
                      border: Border.all(color: kSteamAccent.withValues(alpha: 0.4), width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedFontSize,
                      dropdownColor: kSteamDark,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, color: kSteamAccent, size: 20),
                      items: ['Small', 'Medium', 'Large'].map((v) => DropdownMenuItem(
                        value: v,
                        child: Text(v, style: GoogleFonts.rajdhani(fontSize: 12, color: kSteamText, fontWeight: FontWeight.w600)),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedFontSize = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: GamingButton(
                    label: 'Save Changes',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings saved successfully!')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: kSteamDark, border: Border(top: BorderSide(color: kSteamMed, width: 1))),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(color: kSteamBg, border: Border.all(color: kSteamMed), borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        const Icon(Icons.search, color: kSteamSubtext, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search games...',
                              hintStyle: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen())),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kSteamMed,
                      shape: BoxShape.circle,
                      border: Border.all(color: kSteamAccent.withValues(alpha: 0.5)),
                    ),
                    child: const Icon(Icons.smart_toy, color: kSteamAccent, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kSteamMed,
                    shape: BoxShape.circle,
                    border: Border.all(color: kSteamAccent.withValues(alpha: 0.5)),
                  ),
                  child: const Icon(Icons.person, color: kSteamAccent, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
