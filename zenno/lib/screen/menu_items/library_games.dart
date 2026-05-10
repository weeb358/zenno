import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/gaming_widgets.dart';
import '../../src/providers.dart';
import '../menu.dart';
import '../game_description.dart';

class LibraryGamesScreen extends ConsumerWidget {
  const LibraryGamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(purchaseHistoryStreamProvider);
    final gamesAsync = ref.watch(gamesStreamProvider);

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
          style: GoogleFonts.rajdhani(
              color: kSteamAccent, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 3),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.transparent, kSteamAccent, Colors.transparent]),
            ),
          ),
        ),
      ),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 8,
          child: purchasesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: kSteamAccent)),
            error: (e, _) => Center(
              child: Text('Error: $e', style: GoogleFonts.rajdhani(color: kSteamRed, fontSize: 13)),
            ),
            data: (purchases) {
              if (purchases.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.collections_bookmark, color: kSteamSubtext, size: 52),
                      const SizedBox(height: 16),
                      Text(
                        'No games purchased yet',
                        style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Buy a game to see it here',
                        style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              final allGames = gamesAsync.valueOrNull ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SteamSectionHeader('Your Library'),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: purchases.length,
                      itemBuilder: (context, index) {
                        final purchase = purchases[index];
                        final name = (purchase['name'] ?? '').toString();
                        final price = (purchase['price'] ?? '').toString();

                        // Find matching full game data for banner image etc.
                        final gameData = allGames.firstWhere(
                          (g) => (g['name'] ?? '').toString().toLowerCase() == name.toLowerCase(),
                          orElse: () => <String, dynamic>{},
                        );
                        final bannerUrl = (gameData['bannerUrl'] ?? '').toString();
                        final gameId = (gameData['id'] ?? name).toString();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Dismissible(
                            key: Key(purchase['id']?.toString() ?? name),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              final purchaseId = purchase['id']?.toString() ?? '';
                              if (purchaseId.isNotEmpty) {
                                ref.read(userDataServiceProvider).removeFromLibrary(purchaseId);
                              }
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: kSteamRed.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
                            ),
                            child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GameDescriptionScreen(
                                  gameName: name,
                                  gamePrice: price,
                                  gameId: gameId,
                                  gameData: gameData.isNotEmpty ? gameData : null,
                                  isPurchased: true,
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
                                  // Banner thumbnail
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(7),
                                      bottomLeft: Radius.circular(7),
                                    ),
                                    child: SizedBox(
                                      width: 90,
                                      height: 75,
                                      child: bannerUrl.isNotEmpty
                                          ? Image.network(
                                              bannerUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (ctx, err, st) => _placeholder(),
                                            )
                                          : _placeholder(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name.toUpperCase(),
                                            style: GoogleFonts.rajdhani(
                                                color: kSteamText,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              const Icon(Icons.check_circle, color: kSteamGreen, size: 13),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Purchased',
                                                style: GoogleFonts.rajdhani(
                                                    color: kSteamGreen, fontSize: 12, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          backgroundColor: kSteamDark,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            side: const BorderSide(color: kSteamMed),
                                          ),
                                          title: Text('Remove from Library',
                                              style: GoogleFonts.rajdhani(color: kSteamText, fontWeight: FontWeight.w700, fontSize: 16)),
                                          content: Text(
                                            'Remove "$name" from your library?',
                                            style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: Text('CANCEL', style: GoogleFonts.rajdhani(color: kSteamSubtext, fontWeight: FontWeight.w700)),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: Text('REMOVE', style: GoogleFonts.rajdhani(color: kSteamRed, fontWeight: FontWeight.w700)),
                                            ),
                                          ],
                                        ),
                                      ) ?? false;
                                      if (confirm) {
                                        final purchaseId = purchase['id']?.toString() ?? '';
                                        if (purchaseId.isNotEmpty) {
                                          ref.read(userDataServiceProvider).removeFromLibrary(purchaseId);
                                        }
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                      child: Icon(Icons.delete_outline, color: kSteamRed.withValues(alpha: 0.8), size: 22),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: kSteamMed,
      child: const Icon(Icons.videogame_asset, color: kSteamSubtext, size: 28),
    );
  }
}
