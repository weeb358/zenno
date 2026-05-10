import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';
import '../src/providers.dart';
import 'homescreen.dart';
import 'game_description.dart';

class WishlistGamesScreen extends ConsumerWidget {
  const WishlistGamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistStreamProvider);
    final allGames = ref.watch(gamesStreamProvider).valueOrNull ?? [];

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
              gradient: LinearGradient(
                  colors: [Colors.transparent, kSteamAccent, Colors.transparent]),
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
                const SizedBox(height: 8),
                wishlistAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            children: [
                              const Icon(Icons.favorite_border,
                                  color: kSteamSubtext, size: 56),
                              const SizedBox(height: 16),
                              Text(
                                'Your wishlist is empty.',
                                style: GoogleFonts.rajdhani(
                                    color: kSteamText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Browse games and add them here!',
                                style: GoogleFonts.rajdhani(
                                    color: kSteamSubtext, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.swipe_left,
                                color: kSteamSubtext, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              'Swipe left on a game to remove it',
                              style: GoogleFonts.rajdhani(
                                  color: kSteamSubtext, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final game = items[index];
                            final name = (game['name'] ?? 'Unknown').toString();
                            final price = (game['price'] ?? '').toString();
                            final gameId = (game['id'] ?? name).toString();
                            final isUpcoming = game['isUpcoming'] == true;
                            final discount =
                                ((game['discount'] as num?) ?? 0).toInt();
                            final hasDiscount = !isUpcoming && discount > 0;
                            final raw = double.tryParse(
                                    price.replaceAll(RegExp(r'[^\d.]'), '')) ??
                                0;
                            final discountedPrice = hasDiscount
                                ? '\$${(raw * (1 - discount / 100)).toStringAsFixed(2)}'
                                : price;

                            // Resolve banner: stored value first, then
                            // cross-reference the global games list as fallback
                            String bannerUrl =
                                (game['bannerUrl'] ?? '').toString();
                            if (bannerUrl.isEmpty) {
                              final match = allGames.firstWhere(
                                (g) =>
                                    (g['name'] ?? '')
                                        .toString()
                                        .toLowerCase() ==
                                    name.toLowerCase(),
                                orElse: () => <String, dynamic>{},
                              );
                              bannerUrl =
                                  (match['bannerUrl'] ?? '').toString();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Dismissible(
                                key: Key(gameId),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) {
                                  ref
                                      .read(userDataServiceProvider)
                                      .removeFromWishlist(gameId);
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: kSteamRed.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.delete_outline,
                                      color: Colors.white, size: 26),
                                ),
                                child: GestureDetector(
                                  onTap: isUpcoming
                                      ? () => ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text(
                                                'This game is not released yet.'),
                                          ))
                                      : () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  GameDescriptionScreen(
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
                                      border:
                                          Border.all(color: kSteamMed, width: 1),
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
                                            width: 100,
                                            height: 110,
                                            child: bannerUrl.isNotEmpty
                                                ? Image.network(
                                                    bannerUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (ctx, err, st) =>
                                                            _placeholder(
                                                                isUpcoming),
                                                  )
                                                : _placeholder(isUpcoming),
                                          ),
                                        ),

                                        // Info
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(14),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name.toUpperCase(),
                                                  style: GoogleFonts.rajdhani(
                                                    color: kSteamText,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.5,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                if (hasDiscount) ...[
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 4,
                                                            vertical: 1),
                                                        decoration: BoxDecoration(
                                                          color: kSteamRed,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                        ),
                                                        child: Text(
                                                            '-$discount%',
                                                            style: GoogleFonts
                                                                .rajdhani(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: 10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800)),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        price,
                                                        style:
                                                            GoogleFonts.rajdhani(
                                                          color: kSteamSubtext,
                                                          fontSize: 12,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                          decorationColor:
                                                              kSteamSubtext,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(discountedPrice,
                                                      style: GoogleFonts.rajdhani(
                                                          color: kSteamGreen,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w800)),
                                                ] else
                                                  Text(
                                                    isUpcoming
                                                        ? 'Coming Soon'
                                                        : price,
                                                    style: GoogleFonts.rajdhani(
                                                      color: isUpcoming
                                                          ? kSteamSubtext
                                                          : kSteamGreen,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                const SizedBox(height: 10),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: isUpcoming
                                                          ? kSteamSubtext
                                                          : kSteamAccent,
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    isUpcoming
                                                        ? 'NOT AVAILABLE'
                                                        : 'VIEW DETAILS',
                                                    style: GoogleFonts.rajdhani(
                                                      color: isUpcoming
                                                          ? kSteamSubtext
                                                          : kSteamAccent,
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

                                        // Visible delete button
                                        GestureDetector(
                                          onTap: () async {
                                            final confirm =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                backgroundColor: kSteamDark,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  side: const BorderSide(
                                                      color: kSteamMed),
                                                ),
                                                title: Text(
                                                    'Remove from Wishlist',
                                                    style: GoogleFonts.rajdhani(
                                                        color: kSteamText,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 16)),
                                                content: Text(
                                                  'Remove "$name" from your wishlist?',
                                                  style: GoogleFonts.rajdhani(
                                                      color: kSteamSubtext,
                                                      fontSize: 13),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            ctx, false),
                                                    child: Text('CANCEL',
                                                        style: GoogleFonts
                                                            .rajdhani(
                                                                color:
                                                                    kSteamSubtext,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            ctx, true),
                                                    child: Text('REMOVE',
                                                        style: GoogleFonts
                                                            .rajdhani(
                                                                color: kSteamRed,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                  ),
                                                ],
                                              ),
                                            ) ??
                                                false;
                                            if (confirm) {
                                              ref
                                                  .read(userDataServiceProvider)
                                                  .removeFromWishlist(gameId);
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 16),
                                            child: Icon(Icons.delete_outline,
                                                color: kSteamRed.withValues(
                                                    alpha: 0.8),
                                                size: 22),
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
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: CircularProgressIndicator(color: kSteamAccent),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Text('Error: $e',
                        style: GoogleFonts.rajdhani(color: kSteamRed)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(bool isUpcoming) {
    return Container(
      color: kSteamMed,
      child: Center(
        child: Icon(
          isUpcoming ? Icons.lock_clock : Icons.videogame_asset,
          color: kSteamAccent.withValues(alpha: 0.4),
          size: 32,
        ),
      ),
    );
  }
}
