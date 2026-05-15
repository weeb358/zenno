import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';
import '../src/providers.dart';
import 'checkout.dart';
import 'chat/chatbot.dart';

class GameDescriptionScreen extends ConsumerStatefulWidget {
  final String gameName;
  final String gamePrice;
  final String? gameId;
  final Map<String, dynamic>? gameData;

  const GameDescriptionScreen({
    super.key,
    required this.gameName,
    required this.gamePrice,
    this.gameId,
    this.gameData,
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
    final description = widget.gameData?['description']?.toString() ??
        'Immerse yourself in an epic adventure filled with stunning visuals, captivating storytelling, and challenging gameplay. Experience the ultimate gaming experience.';
    final developer = widget.gameData?['developer']?.toString() ?? '';
    final category = widget.gameData?['category']?.toString() ?? '';
    final publishedDate = widget.gameData?['publishedDate']?.toString() ?? '';
    final systemRequirements = widget.gameData?['systemRequirements']?.toString() ?? '';

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
          'GAME DETAILS',
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
                // Game banner
                Container(
                  width: double.infinity,
                  height: 190,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kSteamMed, kSteamDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: kSteamAccent.withValues(alpha: 0.4), width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.1), blurRadius: 16)],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sports_esports, color: kSteamAccent.withValues(alpha: 0.3), size: 56),
                            const SizedBox(height: 8),
                            Text(
                              widget.gameName.toUpperCase(),
                              style: GoogleFonts.rajdhani(
                                color: kSteamText.withValues(alpha: 0.5),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
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
                          child: Text(
                            widget.gamePrice,
                            style: GoogleFonts.rajdhani(color: kSteamGreen, fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Game name
                Text(
                  widget.gameName,
                  style: GoogleFonts.rajdhani(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: kSteamText,
                    letterSpacing: 1,
                  ),
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
                const SteamSectionHeader('About this Game'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kSteamDark,
                    border: Border.all(color: kSteamMed, width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    description,
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: kSteamText,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // System Requirements
                const SteamSectionHeader('System Requirements'),
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

                // Buy Now
                SizedBox(
                  width: double.infinity,
                  child: GamingButton(
                    label: 'Buy Now — ${widget.gamePrice}',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(gameName: widget.gameName, gamePrice: widget.gamePrice),
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
                          label: _isInCart ? '✓ Added to Cart' : 'Add to Cart',
                          onPressed: _toggleCart,
                          color: _isInCart ? kSteamSubtext : kSteamAccent,
                        ),
                ),
                const SizedBox(height: 10),

                // Wishlist
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
                            _isInWishlist ? 'In Wishlist' : 'Add to Wishlist',
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
      bottomNavigationBar: Container(
        color: kSteamDark,
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
                              hintText: 'Search games...',
                              hintStyle: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: GoogleFonts.rajdhani(color: kSteamText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _navBtn(Icons.smart_toy, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen()))),
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

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: kSteamMed,
          shape: BoxShape.circle,
          border: Border.all(color: kSteamAccent.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: kSteamAccent, size: 20),
      ),
    );
  }
}
