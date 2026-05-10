import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';
import 'package:zenno/src/providers.dart';
import '../game_description.dart';

class SearchGamesScreen extends ConsumerStatefulWidget {
  const SearchGamesScreen({super.key});

  @override
  ConsumerState<SearchGamesScreen> createState() => _SearchGamesScreenState();
}

class _SearchGamesScreenState extends ConsumerState<SearchGamesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static String _formatPrice(String price, String currency) {
    if (price.isEmpty) return '';
    if (price.startsWith('\$') || price.toLowerCase().startsWith('rs')) return price;
    final num = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), ''));
    if (num == null) return price;
    if (currency == 'PKR') return 'Rs. ${num.toInt()}';
    return '\$${num.toStringAsFixed(2)}';
  }

  static String _discountedPrice(String price, int discount, {String currency = 'USD'}) {
    final raw = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    final discounted = raw * (1 - discount / 100);
    if (currency == 'PKR') return 'Rs. ${discounted.toInt()}';
    return '\$${discounted.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(gamesStreamProvider);

    final allGames = gamesAsync.valueOrNull ?? [];
    final results = _query.trim().isEmpty
        ? <Map<String, dynamic>>[]
        : allGames.where((g) {
            final name = (g['name'] ?? '').toString().toLowerCase();
            return name.contains(_query.trim().toLowerCase());
          }).toList();

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
          'SEARCH GAMES',
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
        child: SafeArea(
          child: Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: kSteamDark,
                    border: Border.all(color: kSteamAccent, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search games...',
                      hintStyle: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: kSteamAccent, size: 22),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, color: kSteamSubtext, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ),

              // Results count hint
              if (_query.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      results.isEmpty
                          ? 'No games found for "$_query"'
                          : '${results.length} result${results.length == 1 ? '' : 's'} for "$_query"',
                      style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 12),
                    ),
                  ),
                ),

              // Results list
              Expanded(
                child: _query.trim().isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search, color: kSteamSubtext, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'Type a game name to search',
                              style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.videogame_asset_off,
                                    color: kSteamSubtext, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  'No games found',
                                  style: GoogleFonts.rajdhani(
                                      color: kSteamText,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Try a different search term',
                                  style:
                                      GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              final game = results[index];
                              final name = (game['name'] ?? '').toString();
                              final price = (game['price'] ?? '').toString();
                              final bannerUrl = (game['bannerUrl'] ?? '').toString();
                              final gameId = (game['id'] ?? name).toString();
                              final discount =
                                  ((game['discount'] as num?) ?? 0).toInt();
                              final currency = (game['currency'] ?? 'USD').toString();
                              final hasDiscount = discount > 0;
                              final finalPrice = hasDiscount
                                  ? _discountedPrice(price, discount, currency: currency)
                                  : _formatPrice(price, currency);

                              return Padding(
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
                                        // Thumbnail
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(7),
                                            bottomLeft: Radius.circular(7),
                                          ),
                                          child: SizedBox(
                                            width: 90,
                                            height: 72,
                                            child: bannerUrl.isNotEmpty
                                                ? Image.network(
                                                    bannerUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (ctx, e, st) => Container(
                                                      color: kSteamMed,
                                                      child: Icon(Icons.sports_esports,
                                                          color: kSteamAccent.withValues(alpha: 0.4),
                                                          size: 28),
                                                    ),
                                                  )
                                                : Container(
                                                    color: kSteamMed,
                                                    child: Icon(Icons.sports_esports,
                                                        color: kSteamAccent.withValues(alpha: 0.4),
                                                        size: 28),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name.toUpperCase(),
                                                  style: GoogleFonts.rajdhani(
                                                      color: kSteamText,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w700,
                                                      letterSpacing: 0.5),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                if (hasDiscount) ...[
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 4, vertical: 1),
                                                        decoration: BoxDecoration(
                                                            color: kSteamRed,
                                                            borderRadius:
                                                                BorderRadius.circular(3)),
                                                        child: Text('-$discount%',
                                                            style: GoogleFonts.rajdhani(
                                                                color: Colors.white,
                                                                fontSize: 10,
                                                                fontWeight: FontWeight.w800)),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        _formatPrice(price, currency),
                                                        style: GoogleFonts.rajdhani(
                                                          color: kSteamSubtext,
                                                          fontSize: 11,
                                                          decoration:
                                                              TextDecoration.lineThrough,
                                                          decorationColor: kSteamSubtext,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(finalPrice,
                                                      style: GoogleFonts.rajdhani(
                                                          color: kSteamGreen,
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w800)),
                                                ] else
                                                  Text(price,
                                                      style: GoogleFonts.rajdhani(
                                                          color: kSteamGreen,
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w700)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(right: 12),
                                          child: Icon(Icons.chevron_right,
                                              color: kSteamSubtext, size: 20),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
