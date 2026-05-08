import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';
import 'package:zenno/src/providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(purchaseHistoryStreamProvider);

    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: GamingAppBar(title: 'Purchase History'),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 8,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SteamSectionHeader('Purchased Games'),
                  const SizedBox(height: 16),
                  historyAsync.when(
                    data: (purchases) {
                      if (purchases.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 60),
                            child: Column(
                              children: [
                                Icon(Icons.receipt_long_outlined, color: kSteamSubtext, size: 56),
                                const SizedBox(height: 16),
                                Text(
                                  'No purchases yet.',
                                  style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Buy a game to see your history!',
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
                        itemCount: purchases.length,
                        itemBuilder: (context, index) {
                          final purchase = purchases[index];
                          final name = (purchase['name'] ?? 'Unknown').toString();
                          final price = (purchase['price'] ?? '').toString();
                          final purchasedAt = purchase['purchasedAt'] as int?;
                          final dateStr = purchasedAt != null
                              ? _formatDate(DateTime.fromMillisecondsSinceEpoch(purchasedAt))
                              : '';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: kSteamDark,
                                border: Border.all(color: kSteamMed, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 76,
                                    decoration: BoxDecoration(
                                      color: kSteamMed,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(7),
                                        bottomLeft: Radius.circular(7),
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(Icons.sports_esports, color: kSteamAccent.withValues(alpha: 0.4), size: 28),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: GoogleFonts.rajdhani(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: kSteamText,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            price,
                                            style: GoogleFonts.rajdhani(
                                              fontSize: 13,
                                              color: kSteamGreen,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (dateStr.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              dateStr,
                                              style: GoogleFonts.rajdhani(fontSize: 11, color: kSteamSubtext),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: Icon(Icons.check_circle_outline, color: kSteamGreen, size: 20),
                                  ),
                                ],
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
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day} ${_month(dt.month)} ${dt.year}';
  }

  String _month(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }
}
