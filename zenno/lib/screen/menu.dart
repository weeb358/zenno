import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/src/providers.dart';
import '../widgets/gaming_widgets.dart';
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

  static const _menuItems = [
    {'icon': Icons.collections_bookmark, 'label': 'Library', 'sub': 'Your purchased games'},
    {'icon': Icons.receipt_long, 'label': 'History', 'sub': 'Purchase history'},
    {'icon': Icons.settings, 'label': 'Settings', 'sub': 'App preferences'},
    {'icon': Icons.headset_mic, 'label': 'Support', 'sub': 'Get help'},
    {'icon': Icons.feedback_outlined, 'label': 'Feedback', 'sub': 'Share your thoughts'},
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
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kSteamMed, width: 1))),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ZENNO', style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 4)),
                    Row(
                      children: [
                        _navIcon(context, Icons.home, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Homescreen()))),
                        _navIcon(context, Icons.notifications_outlined, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                        _navIcon(context, Icons.view_agenda_outlined, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UpcomingGamesScreen()))),
                        _navIcon(context, Icons.menu, null, active: true),
                      ],
                    ),
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
                const SteamSectionHeader('Navigation'),
                const SizedBox(height: 16),
                ..._menuItems.map((item) => Padding(
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
                                    item['label'] as String,
                                    style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 15, fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    item['sub'] as String,
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
                                Text('Sign Out', style: GoogleFonts.rajdhani(color: kSteamRed, fontSize: 15, fontWeight: FontWeight.w700)),
                                Text('Log out of your account', style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 12)),
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: kSteamMed, shape: BoxShape.circle, border: Border.all(color: kSteamAccent.withValues(alpha: 0.5))),
                  child: const Icon(Icons.person, color: kSteamAccent, size: 20),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Icon(icon, color: active ? kSteamAccent : kSteamSubtext, size: 24),
      ),
    );
  }
}
