import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';
import '../src/providers.dart';
import 'homescreen.dart';
import 'game_description.dart';
import 'chat/chatbot.dart';

class WishlistGamesScreen extends ConsumerWidget {
  const WishlistGamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistStreamProvider);

    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: AppBar(
        backgroundColor: kSteamDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kSteamAccent),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const Homescreen()),
          ),
        ),
        title: Text(
          'WISHLIST',
          style: GoogleFonts.rajdhani(
            color: kSteamAccent,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 3,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SteamSectionHeader('Saved Games'),
                const SizedBox(height: 14),
                wishlistAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            children: [
                              Icon(Icons.favorite_border, color: kSteamSubtext, size: 56),
                              const SizedBox(height: 16),
                              Text(
                                'Your wishlist is empty.',
                                style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Browse games and add them here!',
                                style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final game = items[index];
                        final name = (game['name'] ?? 'Unknown').toString();
                        final price = (game['price'] ?? '').toString();
                        final gameId = (game['id'] ?? name).toString();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GameDescriptionScreen(
                                  gameName: name,
                                  gamePrice: price,
                                  gameId: gameId,
                                  gameData: game,
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
                                    width: 100,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      color: kSteamMed,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(7),
                                        bottomLeft: Radius.circular(7),
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(Icons.sports_esports, color: kSteamAccent.withValues(alpha: 0.4), size: 36),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name.toUpperCase(),
                                            style: GoogleFonts.rajdhani(
                                              color: kSteamText,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            price,
                                            style: GoogleFonts.rajdhani(
                                              color: kSteamGreen,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: kSteamAccent, width: 1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'VIEW DETAILS',
                                              style: GoogleFonts.rajdhani(
                                                color: kSteamAccent,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: Icon(Icons.chevron_right, color: kSteamSubtext, size: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: CircularProgressIndicator(color: kSteamAccent),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Text('Error: $e', style: GoogleFonts.rajdhani(color: kSteamRed)),
                  ),
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
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: kSteamBg,
                      border: Border.all(color: kSteamMed),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        const Icon(Icons.search, color: kSteamSubtext, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search...',
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
                _navBtn(context, Icons.smart_toy, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen()))),
                const SizedBox(width: 10),
                _navBtn(context, Icons.home, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Homescreen()))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: kSteamMed,
          shape: BoxShape.circle,
          border: Border.all(color: kSteamAccent.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, color: kSteamAccent, size: 20),
      ),
    );
  }
}
