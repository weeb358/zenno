import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';
import 'homescreen.dart';
import 'notifications.dart';
import 'menu.dart';
import 'game_description.dart';

class UpcomingGamesScreen extends StatelessWidget {
  const UpcomingGamesScreen({super.key});

  static const List<Map<String, String>> _upcomingGames = [
    {'name': 'Cyber Nomad 2', 'price': '\$29.99', 'date': 'Jun 2026'},
    {'name': 'Shadow Realm Origins', 'price': '\$39.99', 'date': 'Jul 2026'},
    {'name': 'Void Striker X', 'price': '\$49.99', 'date': 'Aug 2026'},
    {'name': 'Neon Uprising', 'price': '\$59.99', 'date': 'Sep 2026'},
    {'name': 'Iron Throne Wars', 'price': '\$34.99', 'date': 'Oct 2026'},
    {'name': 'Abyss Protocol', 'price': '\$44.99', 'date': 'Nov 2026'},
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
                        _navIcon(context, Icons.notifications_outlined, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                        _navIcon(context, Icons.view_agenda_outlined, null, active: true),
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
          particleCount: 8,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SteamSectionHeader('Coming Soon'),
                const SizedBox(height: 6),
                Text(
                  'Pre-register for upcoming releases',
                  style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                ),
                const SizedBox(height: 18),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _upcomingGames.length,
                  itemBuilder: (context, index) {
                    final game = _upcomingGames[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameDescriptionScreen(
                              gameName: game['name']!,
                              gamePrice: game['price']!,
                            ),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: kSteamDark,
                            border: Border.all(color: kSteamMed, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Banner
                              Container(
                                width: double.infinity,
                                height: 160,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [kSteamMed, kSteamBg],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(7),
                                    topRight: Radius.circular(7),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Icon(Icons.sports_esports, color: kSteamAccent.withValues(alpha: 0.2), size: 60),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: kSteamBg.withValues(alpha: 0.8),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: kSteamAccent.withValues(alpha: 0.5)),
                                        ),
                                        child: Text(
                                          game['date']!,
                                          style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 11, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            game['name']!.toUpperCase(),
                                            style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            game['price']!,
                                            style: GoogleFonts.rajdhani(color: kSteamGreen, fontSize: 14, fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: kSteamAccent),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'PRE-ORDER',
                                        style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: kSteamDark,
          border: Border(top: BorderSide(color: kSteamMed, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
