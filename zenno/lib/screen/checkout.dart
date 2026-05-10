// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';
import '../src/providers.dart';
import '../src/translations.dart';
import 'checkout_success.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String gameName;
  final String gamePrice;
  final String? gameId;
  final String bannerUrl;

  const CheckoutScreen({
    super.key,
    required this.gameName,
    required this.gamePrice,
    this.gameId,
    this.bannerUrl = '',
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _processing = false;

  double _parsePrice(String price) {
    final cleaned = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  void _showConfirmDialog(double walletBalance, double gamePrice) {
    final remaining = walletBalance - gamePrice;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: kSteamDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: kSteamMed),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kSteamAccent.withValues(alpha: 0.15),
                  border: Border.all(color: kSteamAccent, width: 1.5),
                ),
                child: const Center(
                  child: Icon(Icons.account_balance_wallet, color: kSteamAccent, size: 26),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                tr('confirm_purchase'),
                style: GoogleFonts.rajdhani(
                  fontSize: 16, fontWeight: FontWeight.w800, color: kSteamText, letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '"${widget.gameName}"',
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(fontSize: 14, color: kSteamText, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _summaryRow(tr('game_price'), widget.gamePrice, kSteamGreen),
              const SizedBox(height: 6),
              _summaryRow(tr('wallet_balance_label'), '\$${walletBalance.toStringAsFixed(2)}', kSteamSubtext),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: kSteamMed),
              ),
              _summaryRow(
                tr('after_purchase'),
                '\$${remaining.toStringAsFixed(2)}',
                remaining >= 0 ? kSteamText : kSteamRed,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kSteamMed),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        tr('cancel'),
                        style: GoogleFonts.rajdhani(color: kSteamSubtext, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _processPayment(gamePrice);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSteamAccent,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text(
                        tr('confirm'),
                        style: GoogleFonts.rajdhani(color: kSteamBg, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment(double gamePrice) async {
    if (_processing) return;
    setState(() => _processing = true);

    final userDataService = ref.read(userDataServiceProvider);

    final success = await userDataService.deductFromWallet(gamePrice);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient wallet balance!'),
            backgroundColor: kSteamRed,
          ),
        );
        setState(() => _processing = false);
      }
      return;
    }

    await userDataService.savePurchase(
      widget.gameName,
      widget.gamePrice,
      bannerUrl: widget.bannerUrl,
    );

    final id = widget.gameId ?? widget.gameName;
    await userDataService.removeFromWishlist(id);
    await userDataService.removeFromCart(id);

    if (!mounted) return;
    setState(() => _processing = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => CheckoutSuccessScreen(gameName: widget.gameName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    final walletBalance = profileAsync.maybeWhen(
      data: (p) => ((p?['wallet'] as num?) ?? 0.0).toDouble(),
      orElse: () => 0.0,
    );
    final gamePrice = _parsePrice(widget.gamePrice);
    final hasEnoughBalance = walletBalance >= gamePrice;

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
          tr('checkout_title'),
          style: GoogleFonts.rajdhani(
            color: kSteamAccent, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 3,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, kSteamAccent, Colors.transparent],
              ),
            ),
          ),
        ),
      ),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Order summary ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kSteamMed, kSteamDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: kSteamAccent.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 70,
                          height: 52,
                          child: widget.bannerUrl.isNotEmpty
                              ? Image.network(
                                  widget.bannerUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, e, _) => _gameIcon(),
                                )
                              : _gameIcon(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.gameName,
                              style: GoogleFonts.rajdhani(
                                color: kSteamText, fontWeight: FontWeight.w800, fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.gamePrice,
                              style: GoogleFonts.rajdhani(
                                color: kSteamGreen, fontWeight: FontWeight.w800, fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Wallet section ─────────────────────────────────
                SteamSectionHeader(tr('payment_method')),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kSteamDark,
                    border: Border.all(
                      color: hasEnoughBalance
                          ? kSteamAccent.withValues(alpha: 0.5)
                          : kSteamRed.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: hasEnoughBalance ? kSteamAccent : kSteamRed,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tr('zenno_wallet'),
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: hasEnoughBalance ? kSteamAccent : kSteamRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr('available_balance'),
                            style: GoogleFonts.rajdhani(fontSize: 13, color: kSteamSubtext),
                          ),
                          profileAsync.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: kSteamAccent),
                                )
                              : Text(
                                  '\$${walletBalance.toStringAsFixed(2)}',
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: hasEnoughBalance ? kSteamGreen : kSteamRed,
                                  ),
                                ),
                        ],
                      ),
                      if (!hasEnoughBalance && !profileAsync.isLoading) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: kSteamRed.withValues(alpha: 0.08),
                            border: Border.all(color: kSteamRed.withValues(alpha: 0.4)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: kSteamRed, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tr('insufficient_msg'),
                                  style: GoogleFonts.rajdhani(fontSize: 12, color: kSteamRed),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Total ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: kSteamDark,
                    border: Border.all(color: kSteamAccent.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr('total'),
                        style: GoogleFonts.rajdhani(
                          fontSize: 14, fontWeight: FontWeight.w700, color: kSteamSubtext, letterSpacing: 1,
                        ),
                      ),
                      Text(
                        widget.gamePrice,
                        style: GoogleFonts.rajdhani(
                          fontSize: 20, fontWeight: FontWeight.w800, color: kSteamGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Pay button ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: _processing
                      ? const Center(child: CircularProgressIndicator(color: kSteamAccent))
                      : GamingButton(
                          label: hasEnoughBalance ? tr('pay_wallet') : tr('insufficient'),
                          onPressed: hasEnoughBalance && !profileAsync.isLoading
                              ? () => _showConfirmDialog(walletBalance, gamePrice)
                              : () {},
                          color: hasEnoughBalance ? kSteamGreen : kSteamSubtext,
                        ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gameIcon() => Container(
        color: kSteamBg,
        child: const Center(
          child: Icon(Icons.sports_esports, color: kSteamAccent, size: 28),
        ),
      );

  Widget _summaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.rajdhani(fontSize: 12, color: kSteamSubtext)),
        Text(value, style: GoogleFonts.rajdhani(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor)),
      ],
    );
  }
}
