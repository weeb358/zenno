import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';
import '../src/providers.dart';
import 'categories/action_games.dart';
import 'categories/horror_games.dart';
import 'categories/coops_games.dart';
import 'categories/sports_games.dart';
import 'upcoming_games.dart';
import 'wishlist_games.dart';
import 'cart/cart_screen.dart';
import 'notifications.dart';
import 'menu.dart';
import 'wallet.dart';
import 'profile.dart';
import 'game_description.dart';
import 'chat/chatbot.dart';

class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key});

  @override
  ConsumerState<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  String _selectedCategory = 'ACTION';
  int _currentSlide = 0;
  late PageController _pageController;
  final List<String> _categories = ['ACTION', 'HORROR', 'CO-OPS', 'SPORTS'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCategoryPage(String category) {
    switch (category) {
      case 'ACTION': return const ActionGamesScreen();
      case 'HORROR': return const HorrorGamesScreen();
      case 'CO-OPS': return const CoOpsGamesScreen();
      case 'SPORTS': return const SportsGamesScreen();
      default: return const ActionGamesScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(gamesStreamProvider);

    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: kSteamDark,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kSteamMed, width: 1)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    Text(
                      'ZENNO',
                      style: GoogleFonts.rajdhani(
                        color: kSteamAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                      ),
                    ),
                    // Nav icons
                    Row(
                      children: [
                        _navIcon(Icons.home, true, null),
                        _navIcon(Icons.notifications_outlined, false, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                        }),
                        _navIcon(Icons.view_agenda_outlined, false, () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UpcomingGamesScreen()));
                        }),
                        _navIcon(Icons.menu, false, () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MenuScreen()));
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 10,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action row: categories + wishlist + wallet
                Row(
                  children: [
                    // Category dropdown
                    _CategoryDropdown(
                      value: _selectedCategory,
                      items: _categories,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _selectedCategory = v);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => _buildCategoryPage(v)));
                      },
                    ),
                    const Spacer(),
                    _ActionChip(
                      label: 'WISHLIST',
                      icon: Icons.favorite_border,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistGamesScreen())),
                    ),
                    const SizedBox(width: 8),
                    _ActionChip(
                      label: 'WALLET',
                      icon: Icons.account_balance_wallet_outlined,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
                    ),
                    const SizedBox(width: 8),
                    _ActionChip(
                      label: 'CART',
                      icon: Icons.shopping_cart_outlined,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Featured slider
                _buildFeaturedSlider(gamesAsync.valueOrNull?.take(4).toList() ?? []),
                const SizedBox(height: 20),

                // Games list
                const SteamSectionHeader('Featured Games'),
                const SizedBox(height: 12),
                gamesAsync.when(
                  data: (games) {
                    if (games.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              const Icon(Icons.gamepad_outlined, color: kSteamSubtext, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'No games available.\nAdd games via the admin panel.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 14, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        final game = games[index];
                        final name = (game['name'] ?? 'Unknown').toString();
                        final price = (game['price'] ?? '').toString();
                        final gameId = (game['id'] ?? name).toString();
                        final bannerUrl = (game['bannerUrl'] ?? '').toString();
                        return _GameListTile(
                          name: name,
                          price: price,
                          bannerUrl: bannerUrl,
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
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(color: kSteamAccent),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'Could not load games.\n$e',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rajdhani(color: kSteamRed, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _navIcon(IconData icon, bool active, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Icon(
          icon,
          color: active ? kSteamAccent : kSteamSubtext,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildFeaturedSlider(List<Map<String, dynamic>> featuredGames) {
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _pageController,
            itemCount: 4,
            onPageChanged: (i) => setState(() => _currentSlide = i),
            itemBuilder: (context, index) {
              if (index < featuredGames.length) {
                return _buildGameSlide(featuredGames[index]);
              }
              return _buildCategorySlide(index);
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return GestureDetector(
              onTap: () => _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: Container(
                width: _currentSlide == index ? 20 : 8,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: _currentSlide == index ? kSteamAccent : kSteamMed,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGameSlide(Map<String, dynamic> game) {
    final name = (game['name'] ?? '').toString();
    final price = (game['price'] ?? '').toString();
    final gameId = (game['id'] ?? name).toString();
    final bannerUrl = (game['bannerUrl'] ?? '').toString();

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => GameDescriptionScreen(gameName: name, gamePrice: price, gameId: gameId, gameData: game),
      )),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: kSteamMed,
          border: Border.all(color: kSteamAccent.withValues(alpha: 0.4), width: 1.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (bannerUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.network(
                  bannerUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _slidePlaceholderContent(name),
                ),
              )
            else
              _slidePlaceholderContent(name),
            // Dark gradient overlay for readability
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
            // Game name
            Positioned(
              bottom: 36,
              left: 12,
              right: 12,
              child: Text(
                name.toUpperCase(),
                style: GoogleFonts.rajdhani(
                  color: kSteamText,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  shadows: [const Shadow(color: Colors.black, blurRadius: 4)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Price + Details
            Positioned(
              bottom: 10,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  if (price.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kSteamDark.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(price, style: GoogleFonts.rajdhani(color: kSteamGreen, fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: kSteamDark,
                      border: Border.all(color: kSteamAccent, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.3), blurRadius: 8)],
                    ),
                    child: Text('DETAILS', style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slidePlaceholderContent(String name) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [kSteamMed, kSteamDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.games, color: kSteamAccent.withValues(alpha: 0.3), size: 48),
            if (name.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(name.toUpperCase(), style: GoogleFonts.rajdhani(fontSize: 16, color: kSteamText.withValues(alpha: 0.5), fontWeight: FontWeight.w700, letterSpacing: 2)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySlide(int index) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _buildCategoryPage(_categories[index % _categories.length]))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kSteamMed, kSteamDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
          border: Border.all(color: kSteamAccent.withValues(alpha: 0.4), width: 1.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.games, color: kSteamAccent.withValues(alpha: 0.3), size: 48),
                  const SizedBox(height: 8),
                  Text(
                    _categories[index % _categories.length],
                    style: GoogleFonts.rajdhani(fontSize: 22, color: kSteamText.withValues(alpha: 0.5), fontWeight: FontWeight.w700, letterSpacing: 3),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: kSteamDark,
                  border: Border.all(color: kSteamAccent, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.3), blurRadius: 8)],
                ),
                child: Text('EXPLORE', style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
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
                            hintText: 'Search games...',
                            hintStyle: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _navCircle(Icons.smart_toy, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen()));
              }),
              const SizedBox(width: 10),
              _navCircle(Icons.person, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navCircle(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kSteamMed,
          border: Border.all(color: kSteamAccent.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Icon(icon, color: kSteamAccent, size: 20),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdown({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kSteamDark,
        border: Border.all(color: kSteamAccent.withValues(alpha: 0.5), width: 1.5),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.15), blurRadius: 8)],
      ),
      child: DropdownButton<String>(
        value: value,
        dropdownColor: kSteamDark,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: kSteamAccent, size: 22),
        items: items.map((v) => DropdownMenuItem(
          value: v,
          child: Text(v, style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13, fontWeight: FontWeight.w600)),
        )).toList(),
        selectedItemBuilder: (_) => items.map((_) => Text(
          'CATEGORIES',
          style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionChip({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: kSteamDark,
          border: Border.all(color: kSteamMed, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(icon, color: kSteamAccent, size: 14),
            const SizedBox(width: 5),
            Text(label, style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _GameListTile extends StatelessWidget {
  final String name;
  final String price;
  final String bannerUrl;
  final VoidCallback onTap;

  const _GameListTile({required this.name, required this.price, required this.onTap, this.bannerUrl = ''});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: kSteamDark,
            border: Border.all(color: kSteamMed, width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
                child: SizedBox(
                  width: 90,
                  height: 70,
                  child: bannerUrl.isNotEmpty
                      ? Image.network(
                          bannerUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: kSteamMed,
                            child: Icon(Icons.sports_esports, color: kSteamAccent.withValues(alpha: 0.4), size: 28),
                          ),
                        )
                      : Container(
                          color: kSteamMed,
                          child: Icon(Icons.sports_esports, color: kSteamAccent.withValues(alpha: 0.4), size: 28),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
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
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
  }
}
