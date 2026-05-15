import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/gaming_widgets.dart';
import '../menu.dart';
import '../game_description.dart';
import '../chat/chatbot.dart';

class LibraryGamesScreen extends StatelessWidget {
  const LibraryGamesScreen({super.key});

  static const _libraryGames = [
    {'name': 'Cyber Nomad', 'price': '\$29.99', 'genre': 'Action'},
    {'name': 'Shadow Realm', 'price': '\$39.99', 'genre': 'RPG'},
    {'name': 'Neon Racers', 'price': '\$19.99', 'genre': 'Racing'},
    {'name': 'Void Protocol', 'price': '\$49.99', 'genre': 'Strategy'},
  ];

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
          'GAMES LIBRARY',
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
                const SteamSectionHeader('Your Library'),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _libraryGames.length,
                  itemBuilder: (context, index) {
                    final game = _libraryGames[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
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
                          child: Row(
                            children: [
                              Container(
                                width: 90,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: kSteamMed,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                ),
                                child: const Icon(Icons.videogame_asset, color: kSteamSubtext, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        game['name']!.toUpperCase(),
                                        style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        game['genre']!,
                                        style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 11),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        game['price']!,
                                        style: GoogleFonts.rajdhani(color: kSteamGreen, fontSize: 13, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: kSteamAccent, width: 1.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'PLAY',
                                    style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
                                  ),
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
                              hintText: 'Search library...',
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
