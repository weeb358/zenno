import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';
import 'homescreen.dart';
import 'upcoming_games.dart';
import 'menu.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _notifications = [
    {'title': 'New Game Available', 'desc': 'Cyber Nomad 2 is now available on Zenno!', 'icon': Icons.new_releases, 'time': '2m ago'},
    {'title': 'Flash Sale — 50% OFF', 'desc': 'Limited time deal on action games', 'icon': Icons.local_offer, 'time': '1h ago'},
    {'title': 'Wishlist Price Drop', 'desc': 'A game on your wishlist is now cheaper!', 'icon': Icons.trending_down, 'time': '3h ago'},
    {'title': 'New Release This Week', 'desc': 'Shadow Realm Origins drops Friday', 'icon': Icons.calendar_today, 'time': '5h ago'},
    {'title': 'Achievement Unlocked', 'desc': 'You played 10+ hours this week!', 'icon': Icons.emoji_events, 'time': '1d ago'},
    {'title': 'Game Update Ready', 'desc': 'Update available for one of your games', 'icon': Icons.system_update, 'time': '2d ago'},
  ];

  @override
  Widget build(BuildContext context) {
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
                        _navIcon(context, Icons.notifications, null, active: true),
                        _navIcon(context, Icons.view_agenda_outlined, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UpcomingGamesScreen()))),
                        _navIcon(context, Icons.menu, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MenuScreen()))),
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
          particleCount: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SteamSectionHeader('Notifications'),
                const SizedBox(height: 16),
                ..._notifications.map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(n['title'] as String)),
                    ),
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
                              ),
                              child: Icon(n['icon'] as IconData, color: kSteamAccent, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          n['title'] as String,
                                          style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13, fontWeight: FontWeight.w700),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(n['time'] as String, style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 11)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    n['desc'] as String,
                                    style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
