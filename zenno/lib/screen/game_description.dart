import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';
import '../src/providers.dart';
import '../src/translations.dart';
import 'checkout.dart';

class GameDescriptionScreen extends ConsumerStatefulWidget {
  final String gameName;
  final String gamePrice;
  final String? gameId;
  final Map<String, dynamic>? gameData;
  final bool isPurchased;

  const GameDescriptionScreen({
    super.key,
    required this.gameName,
    required this.gamePrice,
    this.gameId,
    this.gameData,
    this.isPurchased = false,
  });

  @override
  ConsumerState<GameDescriptionScreen> createState() => _GameDescriptionScreenState();
}

class _GameDescriptionScreenState extends ConsumerState<GameDescriptionScreen> {
  bool _isInWishlist = false;
  bool _loadingWishlist = false;
  bool _isInCart = false;
  bool _loadingCart = false;

  String get _effectiveGameId => widget.gameId ?? widget.gameName;

  static String _formatRawPrice(String price, String currency) {
    if (price.isEmpty) return '';
    if (price.startsWith('\$') || price.toLowerCase().startsWith('rs')) return price;
    final num = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), ''));
    if (num == null) return price;
    if (currency == 'PKR') return 'Rs. ${num.toInt()}';
    return '\$${num.toStringAsFixed(2)}';
  }

  static String _calcDiscountedPrice(String price, int discount, {String currency = 'USD'}) {
    final raw = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    final discounted = raw * (1 - discount / 100);
    if (currency == 'PKR') return 'Rs. ${discounted.toInt()}';
    return '\$${discounted.toStringAsFixed(2)}';
  }

  Widget _bannerPlaceholder() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kSteamMed, kSteamDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_esports, color: kSteamAccent.withValues(alpha: 0.3), size: 56),
              const SizedBox(height: 8),
              Text(
                widget.gameName.toUpperCase(),
                style: GoogleFonts.rajdhani(color: kSteamText.withValues(alpha: 0.5), fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final service = ref.read(userDataServiceProvider);
    final inWishlist = await service.isInWishlist(_effectiveGameId);
    final inCart = await service.isInCart(_effectiveGameId);
    if (mounted) setState(() { _isInWishlist = inWishlist; _isInCart = inCart; });
  }

  Future<void> _toggleWishlist() async {
    setState(() => _loadingWishlist = true);
    final service = ref.read(userDataServiceProvider);
    try {
      if (_isInWishlist) {
        await service.removeFromWishlist(_effectiveGameId);
        setState(() => _isInWishlist = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${widget.gameName} removed from wishlist')),
          );
        }
      } else {
        await service.addToWishlist({
          'id': _effectiveGameId,
          'name': widget.gameName,
          'price': widget.gamePrice,
          ...?widget.gameData,
        });
        setState(() => _isInWishlist = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${widget.gameName} added to wishlist!')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _loadingWishlist = false);
    }
  }

  Future<void> _toggleCart() async {
    setState(() => _loadingCart = true);
    final service = ref.read(userDataServiceProvider);
    try {
      if (_isInCart) {
        await service.removeFromCart(_effectiveGameId);
        setState(() => _isInCart = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${widget.gameName} removed from cart')),
          );
        }
      } else {
        await service.addToCart({
          'id': _effectiveGameId,
          'name': widget.gameName,
          'price': widget.gamePrice,
          ...?widget.gameData,
        });
        setState(() => _isInCart = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${widget.gameName} added to cart!')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _loadingCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bannerUrl = (widget.gameData?['bannerUrl'] ?? '').toString();
    final description = widget.gameData?['description']?.toString() ??
        'Immerse yourself in an epic adventure filled with stunning visuals, captivating storytelling, and challenging gameplay. Experience the ultimate gaming experience.';
    final developer = widget.gameData?['developer']?.toString() ?? '';
    final category = widget.gameData?['category']?.toString() ?? '';
    final publishedDate = widget.gameData?['publishedDate']?.toString() ?? '';
    final systemRequirements = widget.gameData?['systemRequirements']?.toString() ?? '';
    final discount = ((widget.gameData?['discount'] as num?) ?? 0).toInt();
    final currency = (widget.gameData?['currency'] ?? 'USD').toString();
    final hasDiscount = discount > 0;
    final displayPrice = _formatRawPrice(widget.gamePrice, currency);
    final discountedPrice = hasDiscount
        ? _calcDiscountedPrice(widget.gamePrice, discount, currency: currency)
        : displayPrice;

    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: AppBar(
        backgroundColor: kSteamDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kSteamAccent),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          tr('game_details'),
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
                // Game banner
                Container(
                  width: double.infinity,
                  height: 190,
                  decoration: BoxDecoration(
                    border: Border.all(color: kSteamAccent.withValues(alpha: 0.4), width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.1), blurRadius: 16)],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (bannerUrl.isNotEmpty)
                        Image.network(bannerUrl, fit: BoxFit.cover, errorBuilder: (ctx, e, st) => _bannerPlaceholder())
                      else
                        _bannerPlaceholder(),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: kSteamDark.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: kSteamGreen, width: 1),
                          ),
                          child: hasDiscount
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(color: kSteamRed, borderRadius: BorderRadius.circular(3)),
                                      child: Text('-$discount%', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      displayPrice,
                                      style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 12, decoration: TextDecoration.lineThrough, decorationColor: kSteamSubtext),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(discountedPrice, style: GoogleFonts.rajdhani(color: kSteamGreen, fontWeight: FontWeight.w800, fontSize: 16)),
                                  ],
                                )
                              : Text(displayPrice, style: GoogleFonts.rajdhani(color: kSteamGreen, fontWeight: FontWeight.w800, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Game name
                Text(
                  widget.gameName,
                  style: GoogleFonts.rajdhani(fontSize: 22, fontWeight: FontWeight.w800, color: kSteamText, letterSpacing: 1),
                ),
                const SizedBox(height: 10),

                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (category.isNotEmpty) _tag(category, Icons.category_outlined),
                    if (developer.isNotEmpty) _tag(developer, Icons.code),
                    if (publishedDate.isNotEmpty) _tag(publishedDate, Icons.calendar_today_outlined),
                  ],
                ),
                const SizedBox(height: 18),

                // About game
                SteamSectionHeader(tr('about_game')),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kSteamDark,
                    border: Border.all(color: kSteamMed, width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(description, style: GoogleFonts.rajdhani(fontSize: 14, color: kSteamText, height: 1.6)),
                ),
                const SizedBox(height: 18),

                // System Requirements
                SteamSectionHeader(tr('system_req')),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kSteamDark,
                    border: Border.all(color: kSteamMed, width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    systemRequirements.isNotEmpty
                        ? systemRequirements
                        : 'OS: Windows 10 64-bit\nProcessor: Intel Core i5\nMemory: 8 GB RAM\nGraphics: NVIDIA GeForce GTX 1060',
                    style: GoogleFonts.rajdhani(fontSize: 13, color: kSteamSubtext, height: 1.6),
                  ),
                ),
                const SizedBox(height: 20),

                if (widget.isPurchased) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: kSteamGreen.withValues(alpha: 0.1),
                      border: Border.all(color: kSteamGreen, width: 1.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: kSteamGreen, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          tr('you_purchased'),
                          style: GoogleFonts.rajdhani(color: kSteamGreen, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else ...[
                  // Buy Now
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(
                      label: '${tr('buy_now')} — $displayPrice',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            gameName: widget.gameName,
                            gamePrice: widget.gamePrice,
                            gameId: _effectiveGameId,
                            bannerUrl: (widget.gameData?['bannerUrl'] ?? '').toString(),
                          ),
                        ),
                      ),
                      color: kSteamGreen,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Add to Cart
                  SizedBox(
                    width: double.infinity,
                    child: _loadingCart
                        ? const Center(child: CircularProgressIndicator(color: kSteamAccent))
                        : GamingButton(
                            label: _isInCart ? tr('added_to_cart') : tr('add_to_cart'),
                            onPressed: _toggleCart,
                            color: _isInCart ? kSteamSubtext : kSteamAccent,
                          ),
                  ),
                  const SizedBox(height: 10),
                ],

                if (!widget.isPurchased)
                  SizedBox(
                    width: double.infinity,
                    child: _loadingWishlist
                        ? const Center(child: CircularProgressIndicator(color: kSteamAccent))
                        : OutlinedButton.icon(
                            onPressed: _toggleWishlist,
                            icon: Icon(
                              _isInWishlist ? Icons.favorite : Icons.favorite_border,
                              color: _isInWishlist ? kSteamRed : kSteamSubtext,
                              size: 18,
                            ),
                            label: Text(
                              _isInWishlist ? tr('in_wishlist') : tr('add_wishlist'),
                              style: GoogleFonts.rajdhani(
                                color: _isInWishlist ? kSteamRed : kSteamSubtext,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: _isInWishlist ? kSteamRed : kSteamMed),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: kSteamMed,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: kSteamAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kSteamAccent, size: 12),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.rajdhani(fontSize: 12, color: kSteamText, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

}
