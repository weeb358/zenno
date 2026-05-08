import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class BrowseCategoriesScreen extends StatelessWidget {
  const BrowseCategoriesScreen({super.key});

  static const _categories = [
    {'label': 'Action', 'icon': Icons.local_fire_department},
    {'label': 'RPG', 'icon': Icons.auto_awesome},
    {'label': 'Strategy', 'icon': Icons.psychology},
    {'label': 'Puzzle', 'icon': Icons.extension},
    {'label': 'Horror', 'icon': Icons.nightlight},
    {'label': 'Sports', 'icon': Icons.sports_soccer},
    {'label': 'Racing', 'icon': Icons.speed},
    {'label': 'Indie', 'icon': Icons.brush},
    {'label': 'MMO', 'icon': Icons.people},
    {'label': 'Co-op', 'icon': Icons.handshake},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: GamingAppBar(title: 'BROWSE CATEGORIES'),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 10,
          child: SafeArea(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return Container(
                  decoration: BoxDecoration(
                    color: kSteamDark,
                    border: Border.all(color: kSteamMed, width: 1),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.06), blurRadius: 10)],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(cat['icon'] as IconData, color: kSteamAccent, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            cat['label'] as String,
                            style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.w700, color: kSteamText, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
