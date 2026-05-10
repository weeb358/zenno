import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/src/providers.dart';
import '../widgets/gaming_widgets.dart';
import '../src/translations.dart';
import 'homescreen.dart';
import 'notifications.dart';
import 'upcoming_games.dart';
import 'menu_items/library_games.dart';
import 'menu_items/history.dart';
import 'menu_items/support.dart';
import 'menu_items/settings.dart';
import 'menu_items/feedback.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  static const _menuItemKeys = [
    {'icon': Icons.collections_bookmark, 'label': 'Library', 'labelKey': 'library', 'subKey': 'library_sub'},
    {'icon': Icons.receipt_long, 'label': 'History', 'labelKey': 'history_menu', 'subKey': 'history_sub'},
    {'icon': Icons.settings, 'label': 'Settings', 'labelKey': 'settings_menu', 'subKey': 'settings_sub'},
    {'icon': Icons.headset_mic, 'label': 'Support', 'labelKey': 'support', 'subKey': 'support_sub'},
    {'icon': Icons.feedback_outlined, 'label': 'Feedback', 'labelKey': 'feedback', 'subKey': 'feedback_sub'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: kSteamDark,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _navIcon(context, Icons.home_rounded, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Homescreen()))),
                    _navIcon(context, Icons.notifications_outlined, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                    _navIcon(context, Icons.grid_view_rounded, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UpcomingGamesScreen()))),
                    _navIcon(context, Icons.menu_rounded, null, active: true),
                  ],
                ),
              ),
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
                SteamSectionHeader(tr('navigation')),
                const SizedBox(height: 16),
                ..._menuItemKeys.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => _navigate(context, item['label'] as String, ref),
                    child: Container(
                      decoration: BoxDecoration(
                        color: kSteamDark,
                        border: Border.all(color: kSteamMed, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: kSteamMed,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: kSteamAccent.withValues(alpha: 0.3)),
                              ),
                              child: Icon(item['icon'] as IconData, color: kSteamAccent, size: 22),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tr(item['labelKey'] as String),
                                    style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 15, fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    tr(item['subKey'] as String),
                                    style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: kSteamSubtext, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _signOut(context, ref),
                  child: Container(
                    decoration: BoxDecoration(
                      color: kSteamDark,
                      border: Border.all(color: kSteamRed.withValues(alpha: 0.5), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: kSteamRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: kSteamRed.withValues(alpha: 0.4)),
                            ),
                            child: const Icon(Icons.logout, color: kSteamRed, size: 22),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tr('sign_out'), style: GoogleFonts.rajdhani(color: kSteamRed, fontSize: 15, fontWeight: FontWeight.w700)),
                                Text(tr('sign_out_sub'), style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: kSteamSubtext, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String label, WidgetRef ref) {
    Widget? screen;
    switch (label) {
      case 'Library': screen = const LibraryGamesScreen(); break;
      case 'History': screen = const HistoryGamesScreen(); break;
      case 'Support': screen = const SupportScreen(); break;
      case 'Settings': screen = const SettingsScreen(); break;
      case 'Feedback': screen = const FeedbackScreen(); break;
    }
    if (screen != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen!));
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    ref.read(localAuthSessionProvider.notifier).state = null;
    try {
      await ref.read(authServiceProvider).signOut();
    } catch (_) {}
    if (context.mounted) context.go('/login');
  }

  static Widget _navIcon(BuildContext context, IconData icon, VoidCallback? onTap, {bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? kSteamMed : Colors.transparent,
          border: active ? Border.all(color: kSteamAccent.withValues(alpha: 0.4), width: 1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: active ? kSteamAccent : kSteamSubtext, size: 22),
      ),
    );
  }
}
