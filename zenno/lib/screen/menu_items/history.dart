import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/gaming_widgets.dart';
import '../../src/providers.dart';
import '../../src/translations.dart';
import '../menu.dart';

class HistoryGamesScreen extends ConsumerStatefulWidget {
  const HistoryGamesScreen({super.key});

  @override
  ConsumerState<HistoryGamesScreen> createState() => _HistoryGamesScreenState();
}

class _HistoryGamesScreenState extends ConsumerState<HistoryGamesScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
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
          tr('history'),
          style: GoogleFonts.rajdhani(
              color: kSteamAccent,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: 3),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                kSteamAccent,
                Colors.transparent
              ]),
            ),
          ),
        ),
      ),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 8,
          child: Column(
            children: [
              // Tabs
              Container(
                color: kSteamDark,
                child: Row(
                  children: [
                    _tab(tr('games_tab'), 0),
                    _tab(tr('wallet_tab'), 1),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: _selectedTab == 0
                      ? _GamesTab()
                      : _WalletTab(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(String label, int index) {
    final active = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: active ? kSteamAccent : kSteamMed,
                  width: active ? 2 : 1),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? kSteamAccent : kSteamSubtext,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Games Tab ─────────────────────────────────────────────────────────────────
class _GamesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(purchaseHistoryStreamProvider);
    final allGames = ref.watch(gamesStreamProvider).valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SteamSectionHeader(tr('purchased_games')),
        const SizedBox(height: 16),
        historyAsync.when(
          data: (purchases) {
            if (purchases.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          color: kSteamSubtext, size: 56),
                      const SizedBox(height: 16),
                      Text(tr('no_purchases'),
                          style: GoogleFonts.rajdhani(
                              color: kSteamText,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(tr('buy_game'),
                          style: GoogleFonts.rajdhani(
                              color: kSteamSubtext, fontSize: 13)),
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
                final p = purchases[index];
                final name = (p['name'] ?? 'Unknown').toString();
                final price = (p['price'] ?? '').toString();
                final ts = p['purchasedAt'] as int?;
                final dateStr = ts != null
                    ? _fmtDate(DateTime.fromMillisecondsSinceEpoch(ts))
                    : '';

                String bannerUrl = (p['bannerUrl'] ?? '').toString();
                if (bannerUrl.isEmpty) {
                  final match = allGames.firstWhere(
                    (g) => (g['name'] ?? '').toString().toLowerCase() ==
                        name.toLowerCase(),
                    orElse: () => <String, dynamic>{},
                  );
                  bannerUrl = (match['bannerUrl'] ?? '').toString();
                }

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
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(7),
                            bottomLeft: Radius.circular(7),
                          ),
                          child: SizedBox(
                            width: 90,
                            height: 80,
                            child: bannerUrl.isNotEmpty
                                ? Image.network(bannerUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, st) =>
                                        _imgPlaceholder())
                                : _imgPlaceholder(),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.toUpperCase(),
                                  style: GoogleFonts.rajdhani(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: kSteamText,
                                      letterSpacing: 0.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(price,
                                    style: GoogleFonts.rajdhani(
                                        fontSize: 13,
                                        color: kSteamGreen,
                                        fontWeight: FontWeight.w700)),
                                if (dateStr.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(dateStr,
                                      style: GoogleFonts.rajdhani(
                                          fontSize: 11, color: kSteamSubtext)),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.check_circle_outline,
                              color: kSteamGreen, size: 20),
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
            child: Text('Error: $e',
                style: GoogleFonts.rajdhani(color: kSteamRed)),
          ),
        ),
      ],
    );
  }

  Widget _imgPlaceholder() => Container(
        color: kSteamMed,
        child: Center(
          child: Icon(Icons.videogame_asset,
              color: kSteamAccent.withValues(alpha: 0.4), size: 28),
        ),
      );

  String _fmtDate(DateTime d) {
    const m = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}

// ── Wallet Tab ────────────────────────────────────────────────────────────────
class _WalletTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnAsync = ref.watch(walletTransactionsStreamProvider);
    final profileAsync = ref.watch(userProfileStreamProvider);
    final balance = profileAsync.valueOrNull?['wallet'];
    final walletBalance =
        balance == null ? 0.0 : (balance as num).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current balance chip
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: kSteamDark,
            border:
                Border.all(color: kSteamAccent.withValues(alpha: 0.35), width: 1.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('current_balance'),
                  style: GoogleFonts.rajdhani(
                      fontSize: 11, color: kSteamSubtext, letterSpacing: 1.5)),
              Text(
                '\$${walletBalance.toStringAsFixed(2)}',
                style: GoogleFonts.rajdhani(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kSteamGreen),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        SteamSectionHeader(tr('wallet_topups')),
        const SizedBox(height: 12),

        txnAsync.when(
          data: (txns) {
            if (txns.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined,
                          color: kSteamSubtext, size: 48),
                      const SizedBox(height: 12),
                      Text(tr('no_transactions'),
                          style: GoogleFonts.rajdhani(
                              color: kSteamText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(tr('add_funds_history'),
                          style: GoogleFonts.rajdhani(
                              color: kSteamSubtext, fontSize: 12)),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: txns.length,
              itemBuilder: (context, index) {
                final txn = txns[index];
                final amount =
                    ((txn['amount'] as num?) ?? 0).toDouble();
                final last4 = (txn['cardLast4'] ?? '').toString();
                final ts = txn['addedAt'] as int?;
                final dateStr = ts != null
                    ? _fmtDateTime(DateTime.fromMillisecondsSinceEpoch(ts))
                    : '';
                final isFirst = index == 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kSteamDark,
                      border: Border.all(
                          color: isFirst
                              ? kSteamGreen.withValues(alpha: 0.5)
                              : kSteamMed,
                          width: isFirst ? 1.5 : 1),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isFirst
                          ? [
                              BoxShadow(
                                  color: kSteamGreen.withValues(alpha: 0.08),
                                  blurRadius: 10)
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: kSteamGreen.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              color: kSteamGreen, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr('wallet_topup'),
                                style: GoogleFonts.rajdhani(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: kSteamText),
                              ),
                              const SizedBox(height: 2),
                              if (last4.isNotEmpty)
                                Text('Card: •••• $last4',
                                    style: GoogleFonts.rajdhani(
                                        fontSize: 11, color: kSteamSubtext)),
                              if (dateStr.isNotEmpty)
                                Text(dateStr,
                                    style: GoogleFonts.rajdhani(
                                        fontSize: 10, color: kSteamSubtext)),
                            ],
                          ),
                        ),
                        Text(
                          '+\$${amount.toStringAsFixed(2)}',
                          style: GoogleFonts.rajdhani(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: kSteamGreen),
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
            child: Text('Error: $e',
                style: GoogleFonts.rajdhani(color: kSteamRed)),
          ),
        ),
      ],
    );
  }

  String _fmtDateTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    const m = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}  $h:$min';
  }
}
