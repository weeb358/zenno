import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../src/providers.dart';
import '../widgets/gaming_widgets.dart';
import 'package:zenno/src/widgets/fade_in.dart';
import 'game_description.dart';

class CategoryGamesScreen extends ConsumerWidget {
  final String categoryName;

  const CategoryGamesScreen({
    required this.categoryName,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesByCategoryProvider(categoryName));

    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: AppBar(
        backgroundColor: kSteamDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kSteamAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryName.toUpperCase(),
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
          particleCount: 10,
          child: gamesAsync.when(
            data: (games) {
              if (games.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videogame_asset_off, color: kSteamSubtext, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'No games in this category',
                        style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 15),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  final name = (game['name'] ?? 'Untitled Game').toString();
                  final price = (game['price'] ?? '').toString();
                  final gameId = (game['id'] ?? name).toString();
                  final bannerUrl = (game['bannerUrl'] ?? '').toString();
                  return FadeIn(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
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
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                                child: SizedBox(
                                  width: 90,
                                  height: 72,
                                  child: bannerUrl.isNotEmpty
                                      ? Image.network(
                                          bannerUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Container(
                                            color: kSteamMed,
                                            child: const Icon(Icons.videogame_asset, color: kSteamSubtext, size: 28),
                                          ),
                                        )
                                      : Container(
                                          color: kSteamMed,
                                          child: const Icon(Icons.videogame_asset, color: kSteamSubtext, size: 28),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name.toUpperCase(),
                                        style: GoogleFonts.rajdhani(
                                          color: kSteamText,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        price,
                                        style: GoogleFonts.rajdhani(
                                          color: kSteamGreen,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: kSteamAccent, width: 1.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Details',
                                    style: GoogleFonts.rajdhani(
                                      color: kSteamAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
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
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: kSteamAccent)),
            error: (error, stack) => Center(
              child: Text('Error: $error', style: GoogleFonts.rajdhani(color: kSteamRed, fontSize: 13)),
            ),
          ),
        ),
      ),
    );
  }
}
