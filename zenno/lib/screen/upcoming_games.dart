import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';
import '../src/providers.dart';
import 'homescreen.dart';
import 'notifications.dart';
import 'menu.dart';

class UpcomingGamesScreen extends ConsumerWidget {
  const UpcomingGamesScreen({super.key});

  static String _formatPrice(Map<String, dynamic> game) {
    final price = (game['price'] ?? '').toString();
    final currency = (game['currency'] ?? 'USD').toString();
    if (price.isEmpty) return '';
    if (price.startsWith('\$') || price.toLowerCase().startsWith('rs')) return price;
    final num = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), ''));
    if (num == null) return price;
    if (currency == 'PKR') return 'Rs. ${num.toInt()}';
    return '\$${num.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingGamesStreamProvider);

    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: kSteamDark,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _navIcon(context, Icons.home_rounded, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Homescreen()))),
                    _navIcon(context, Icons.notifications_outlined, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                    _navIcon(context, Icons.grid_view_rounded, null, active: true),
                    _navIcon(context, Icons.menu_rounded, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MenuScreen()))),
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
          child: upcomingAsync.when(
            data: (games) {
              if (games.isEmpty) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SteamSectionHeader('Coming Soon'),
                      const SizedBox(height: 60),
                      Center(
                        child: Column(
                          children: [
                            const Icon(Icons.sports_esports, color: kSteamSubtext, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'No upcoming games announced yet',
                              style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SteamSectionHeader('Coming Soon'),
                    const SizedBox(height: 6),
                    Text(
                      'Tap DETAILS to view info and add to wishlist',
                      style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        final game = games[index];
                        final bannerUrl = (game['bannerUrl'] ?? '').toString();
                        final formattedPrice = _formatPrice(game);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Container(
                            decoration: BoxDecoration(
                              color: kSteamDark,
                              border: Border.all(color: kSteamMed, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Banner with image support
                                Container(
                                  width: double.infinity,
                                  height: 160,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(7),
                                      topRight: Radius.circular(7),
                                    ),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Background: image or gradient fallback
                                      if (bannerUrl.isNotEmpty)
                                        Image.network(
                                          bannerUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => _gradientPlaceholder(),
                                        )
                                      else
                                        _gradientPlaceholder(),
                                      // Gradient overlay for readability
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                                          ),
                                        ),
                                      ),
                                      // Release date badge
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: kSteamBg.withValues(alpha: 0.85),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: kSteamAccent.withValues(alpha: 0.5)),
                                          ),
                                          child: Text(
                                            (game['releaseDate'] ?? '').toString(),
                                            style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 11, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                      // "NOT FOR SALE" overlay badge
                                      const Positioned(
                                        top: 12,
                                        left: 12,
                                        child: _ComingSoonBadge(),
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
                                              (game['name'] ?? '').toString().toUpperCase(),
                                              style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                            ),
                                            const SizedBox(height: 4),
                                            if (formattedPrice.isNotEmpty)
                                              Text(
                                                'Est. $formattedPrice',
                                                style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 12),
                                              ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _showDetailSheet(context, ref, game),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: kSteamAccent),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'DETAILS',
                                            style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: kSteamAccent)),
            error: (e, s) => Center(
              child: Text('Error: $e', style: GoogleFonts.rajdhani(color: kSteamRed, fontSize: 13)),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _gradientPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kSteamMed, kSteamBg],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.sports_esports, color: kSteamAccent.withValues(alpha: 0.2), size: 60),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, WidgetRef ref, Map<String, dynamic> game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSteamDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: kSteamMed, width: 1),
      ),
      isScrollControlled: true,
      builder: (_) => _GameDetailSheet(game: game, ref: ref),
    );
  }

  static Widget _navIcon(BuildContext context, IconData icon, VoidCallback? onTap, {bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? kSteamMed : Colors.transparent,
          border: active ? Border.all(color: kSteamAccent.withValues(alpha: 0.4), width: 1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: active ? kSteamAccent : kSteamSubtext, size: 22),
      ),
    );
  }
}

class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: kSteamAccent.withValues(alpha: 0.5)),
      ),
      child: Text(
        'NOT FOR SALE',
        style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1),
      ),
    );
  }
}

class _GameDetailSheet extends StatefulWidget {
  final Map<String, dynamic> game;
  final WidgetRef ref;

  const _GameDetailSheet({required this.game, required this.ref});

  @override
  State<_GameDetailSheet> createState() => _GameDetailSheetState();
}

class _GameDetailSheetState extends State<_GameDetailSheet> {
  bool _isAdding = false;
  bool _added = false;

  static String _formatPrice(Map<String, dynamic> game) {
    final price = (game['price'] ?? '').toString();
    final currency = (game['currency'] ?? 'USD').toString();
    if (price.isEmpty) return '';
    if (price.startsWith('\$') || price.toLowerCase().startsWith('rs')) return price;
    final num = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), ''));
    if (num == null) return price;
    if (currency == 'PKR') return 'Rs. ${num.toInt()}';
    return '\$${num.toStringAsFixed(2)}';
  }

  Future<void> _addToWishlist() async {
    setState(() => _isAdding = true);
    try {
      final service = widget.ref.read(userDataServiceProvider);
      await service.addToWishlist({
        'id': widget.game['id'] ?? widget.game['name'],
        'name': widget.game['name'] ?? '',
        'price': widget.game['price'] ?? '',
        'isUpcoming': true,
        'releaseDate': widget.game['releaseDate'] ?? '',
      });
      if (mounted) {
        setState(() { _added = true; _isAdding = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to wishlist')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAdding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final bannerUrl = (game['bannerUrl'] ?? '').toString();
    final formattedPrice = _formatPrice(game);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: kSteamMed, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            // Banner
            Container(
              width: double.infinity,
              height: 150,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: bannerUrl.isNotEmpty
                  ? Image.network(
                      bannerUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _fallbackBanner(),
                    )
                  : _fallbackBanner(),
            ),
            const SizedBox(height: 20),
            // Title & release badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    (game['name'] ?? '').toString().toUpperCase(),
                    style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kSteamBg,
                    border: Border.all(color: kSteamAccent.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    (game['releaseDate'] ?? '').toString(),
                    style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Price as estimate + category
            Row(
              children: [
                if (formattedPrice.isNotEmpty) ...[
                  Text(
                    'Est. $formattedPrice',
                    style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: kSteamAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: kSteamAccent.withValues(alpha: 0.4)),
                  ),
                  child: Text('NOT FOR SALE', style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
                if ((game['category'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: kSteamMed, borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      (game['category'] ?? '').toString(),
                      style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            if ((game['description'] ?? '').toString().isNotEmpty) ...[
              Text('About', style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 8),
              Text(
                (game['description'] ?? '').toString(),
                style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 24),
            ] else
              const SizedBox(height: 8),
            // Add to Wishlist button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isAdding
                  ? const Center(child: CircularProgressIndicator(color: kSteamAccent))
                  : ElevatedButton.icon(
                      onPressed: _added ? null : _addToWishlist,
                      icon: Icon(_added ? Icons.check : Icons.favorite_border, size: 18),
                      label: Text(
                        _added ? 'ADDED TO WISHLIST' : 'ADD TO WISHLIST',
                        style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _added ? kSteamMed : kSteamAccent,
                        foregroundColor: _added ? kSteamSubtext : Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _fallbackBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [kSteamMed, kSteamBg], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(
        child: Icon(Icons.sports_esports, color: kSteamAccent.withValues(alpha: 0.3), size: 56),
      ),
    );
  }
}
