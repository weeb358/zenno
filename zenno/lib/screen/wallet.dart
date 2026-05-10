import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';
import '../src/providers.dart';
import '../src/translations.dart';
import 'card_payment.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    final cardsAsync = ref.watch(cardsStreamProvider);

    final balance = profileAsync.valueOrNull?['wallet'];
    final walletBalance = balance == null ? 0.0 : (balance as num).toDouble();

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
          tr('wallet_title'),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kSteamMed, kSteamDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                        color: kSteamAccent.withValues(alpha: 0.4), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: kSteamAccent.withValues(alpha: 0.1),
                          blurRadius: 20)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('wallet_balance_card'),
                          style: GoogleFonts.rajdhani(
                              fontSize: 11,
                              color: kSteamSubtext,
                              letterSpacing: 2)),
                      const SizedBox(height: 8),
                      profileAsync.when(
                        data: (e) => Text(
                          '\$${walletBalance.toStringAsFixed(2)}',
                          style: GoogleFonts.rajdhani(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: kSteamGreen),
                        ),
                        loading: () => const SizedBox(
                          height: 44,
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: kSteamGreen, strokeWidth: 2)),
                        ),
                        error: (e, s) => Text('\$0.00',
                            style: GoogleFonts.rajdhani(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: kSteamGreen)),
                      ),
                      const SizedBox(height: 4),
                      Text(tr('available_to_spend'),
                          style: GoogleFonts.rajdhani(
                              fontSize: 12, color: kSteamSubtext)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section header + Add Card button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SteamSectionHeader(tr('saved_cards')),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddCardScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: kSteamAccent.withValues(alpha: 0.12),
                          border: Border.all(color: kSteamAccent, width: 1.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add,
                                color: kSteamAccent, size: 16),
                            const SizedBox(width: 5),
                            Text(tr('add_card'),
                                style: GoogleFonts.rajdhani(
                                    color: kSteamAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Cards list
                cardsAsync.when(
                  data: (cards) => cards.isEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          decoration: BoxDecoration(
                            color: kSteamDark,
                            border: Border.all(color: kSteamMed),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.credit_card_off,
                                  color: kSteamSubtext, size: 44),
                              const SizedBox(height: 12),
                              Text(tr('no_cards'),
                                  style: GoogleFonts.rajdhani(
                                      color: kSteamText,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(tr('tap_add_card'),
                                  style: GoogleFonts.rajdhani(
                                      color: kSteamSubtext, fontSize: 12)),
                            ],
                          ),
                        )
                      : Column(
                          children: cards
                              .map((card) => Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: _CardTile(card: card),
                                  ))
                              .toList(),
                        ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: kSteamAccent),
                    ),
                  ),
                  error: (e, s) => Text('Error: $e',
                      style: GoogleFonts.rajdhani(color: kSteamRed)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardTile extends ConsumerStatefulWidget {
  final Map<String, dynamic> card;
  const _CardTile({required this.card});

  @override
  ConsumerState<_CardTile> createState() => _CardTileState();
}

class _CardTileState extends ConsumerState<_CardTile> {
  Future<void> _showAddFundsDialog(String last4) async {
    final service = ref.read(userDataServiceProvider);

    await showDialog(
      context: context,
      builder: (ctx) => _AddFundsDialog(
        last4: last4,
        onConfirm: (amount) async {
          await service.addToWallet(amount, cardLast4: last4);
        },
      ),
    );
  }

  Future<void> _confirmRemove(String cardId) async {
    if (cardId.isEmpty) return;
    // Capture service before any async gap
    final service = ref.read(userDataServiceProvider);

    final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: kSteamDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: kSteamMed),
            ),
            title: Text('Remove Card',
                style: GoogleFonts.rajdhani(
                    color: kSteamText,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            content: Text('Remove this card from your wallet?',
                style:
                    GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('CANCEL',
                    style: GoogleFonts.rajdhani(
                        color: kSteamSubtext, fontWeight: FontWeight.w700)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('REMOVE',
                    style: GoogleFonts.rajdhani(
                        color: kSteamRed, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm && mounted) {
      await service.removeCard(cardId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final name = (card['cardholderName'] ?? '').toString();
    final last4 = (card['cardLast4'] ?? '****').toString();
    final expiry = (card['expiry'] ?? '').toString();
    final cardId = (card['id'] ?? '').toString();

    return GestureDetector(
      onTap: () => _showAddFundsDialog(last4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1a237e), Color(0xFF283593)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF1a237e).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CREDIT',
                      style: GoogleFonts.rajdhani(
                          color: Colors.white54,
                          fontSize: 11,
                          letterSpacing: 2),
                    ),
                    const Icon(Icons.wifi, color: Colors.white38, size: 18),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '**** **** **** $last4',
                  style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CARDHOLDER',
                            style: GoogleFonts.rajdhani(
                                color: Colors.white38,
                                fontSize: 8,
                                letterSpacing: 1)),
                        Text(
                          name.isEmpty ? 'NAME' : name.toUpperCase(),
                          style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('EXPIRES',
                            style: GoogleFonts.rajdhani(
                                color: Colors.white38,
                                fontSize: 8,
                                letterSpacing: 1)),
                        Text(
                          expiry.isEmpty ? 'MM/YY' : expiry,
                          style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Remove button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _confirmRemove(cardId),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(20),
                ),
                child:
                    const Icon(Icons.close, color: Colors.white70, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extracted as a StatefulWidget so it manages its own loading state safely
class _AddFundsDialog extends StatefulWidget {
  final String last4;
  final Future<void> Function(double amount) onConfirm;

  const _AddFundsDialog(
      {required this.last4,
      required this.onConfirm});

  @override
  State<_AddFundsDialog> createState() => _AddFundsDialogState();
}

class _AddFundsDialogState extends State<_AddFundsDialog> {
  final _ctrl = TextEditingController();
  bool _adding = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_ctrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }
    setState(() => _adding = true);
    try {
      await widget.onConfirm(amount);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('\$${amount.toStringAsFixed(2)} added to wallet!'),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _adding = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kSteamDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: kSteamAccent, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('add_funds'),
              style: GoogleFonts.rajdhani(
                  color: kSteamAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: 2),
            ),
            const SizedBox(height: 4),
            Text(
              'Card ending in ${widget.last4}',
              style:
                  GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 12),
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: kSteamBg,
                border: Border.all(color: kSteamMed, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Enter amount (e.g. 25.00)',
                  hintStyle: GoogleFonts.rajdhani(
                      color: kSteamSubtext, fontSize: 13),
                  prefixText: '\$  ',
                  prefixStyle: GoogleFonts.rajdhani(
                      color: kSteamGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: kSteamDark,
                        border: Border.all(color: kSteamMed),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text('CANCEL',
                            style: GoogleFonts.rajdhani(
                                color: kSteamSubtext,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: 1)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _adding ? null : _submit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: kSteamGreen.withValues(alpha: 0.15),
                        border: Border.all(color: kSteamGreen, width: 1.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: _adding
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: kSteamGreen, strokeWidth: 2))
                            : Text(tr('add_funds'),
                                style: GoogleFonts.rajdhani(
                                    color: kSteamGreen,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    letterSpacing: 1)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
