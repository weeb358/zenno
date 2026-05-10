import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/gaming_widgets.dart';
import '../../src/providers.dart';
import '../../src/translations.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartStreamProvider);
    final allGames = ref.watch(gamesStreamProvider).valueOrNull ?? [];

    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: AppBar(
        backgroundColor: kSteamDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kSteamAccent),
          onPressed: () => context.pop(),
        ),
        title: Text(
          tr('cart_title'),
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
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SteamSectionHeader(tr('your_cart')),
                  const SizedBox(height: 14),
                  cartAsync.when(
                    data: (items) => items.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 60),
                              child: Column(
                                children: [
                                  Icon(Icons.shopping_cart_outlined, color: kSteamSubtext, size: 56),
                                  const SizedBox(height: 16),
                                  Text(
                                    tr('empty_cart'),
                                    style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    tr('add_games'),
                                    style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: kSteamDark,
                              border: Border.all(color: kSteamMed, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              separatorBuilder: (context, index) => Divider(color: kSteamMed, height: 1),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final name = (item['name'] ?? 'Unknown').toString();
                                final price = (item['price'] ?? '').toString();
                                final gameId = (item['id'] ?? name).toString();
                                String bannerUrl = (item['bannerUrl'] ?? '').toString();
                                if (bannerUrl.isEmpty) {
                                  final match = allGames.firstWhere(
                                    (g) => (g['name'] ?? '').toString().toLowerCase() == name.toLowerCase(),
                                    orElse: () => <String, dynamic>{},
                                  );
                                  bannerUrl = (match['bannerUrl'] ?? '').toString();
                                }
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: SizedBox(
                                          width: 56,
                                          height: 48,
                                          child: bannerUrl.isNotEmpty
                                              ? Image.network(
                                                  bannerUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (ctx, err, st) => Container(
                                                    color: kSteamMed,
                                                    child: Icon(Icons.sports_esports, color: kSteamAccent.withValues(alpha: 0.4), size: 22),
                                                  ),
                                                )
                                              : Container(
                                                  color: kSteamMed,
                                                  child: Icon(Icons.sports_esports, color: kSteamAccent.withValues(alpha: 0.4), size: 22),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: GoogleFonts.rajdhani(
                                                fontWeight: FontWeight.w700,
                                                color: kSteamText,
                                                fontSize: 14,
                                              ),
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
                                      GestureDetector(
                                        onTap: () async {
                                          final service = ref.read(userDataServiceProvider);
                                          await service.removeFromCart(gameId);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: kSteamRed.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Icon(Icons.close, color: kSteamRed, size: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: kSteamAccent),
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Text('Error: $e', style: GoogleFonts.rajdhani(color: kSteamRed)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(label: tr('browse_games'), onPressed: () => context.go('/home')),
                  ),
                  if (cartAsync.valueOrNull?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: GamingButton(
                        label: tr('checkout'),
                        onPressed: () => context.push('/checkout'),
                        color: kSteamGreen,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
