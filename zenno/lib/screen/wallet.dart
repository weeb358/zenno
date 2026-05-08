import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';
import 'card_payment.dart';

class Transaction {
  final String type;
  final double amount;
  final DateTime date;
  final String cardLast4;

  Transaction({
    required this.type,
    required this.amount,
    required this.date,
    required this.cardLast4,
  });
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _totalCredit = 0.00;
  String _selectedPaymentMethod = 'wallet';
  final List<CardData> _savedCards = [];
  final List<Transaction> _transactions = [];

  void _addFunds(double amount) {
    if (_selectedPaymentMethod == 'card') {
      _openCardPayment();
      return;
    }
    setState(() {
      _totalCredit += amount;
      _transactions.add(Transaction(
        type: 'Wallet Top-Up',
        amount: amount,
        date: DateTime.now(),
        cardLast4: 'wallet',
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('\$${amount.toStringAsFixed(2)} added to your wallet!')),
    );
  }

  void _openCardPayment() async {
    final result = await Navigator.push<CardData>(
      context,
      MaterialPageRoute(builder: (_) => const CardPaymentScreen()),
    );
    if (!mounted || result == null) return;
    setState(() {
      _savedCards.add(result);
      _totalCredit += result.amount;
      _transactions.add(Transaction(
        type: 'Card Top-Up',
        amount: result.amount,
        date: result.timestamp,
        cardLast4: result.cardNumber.substring(result.cardNumber.length - 4),
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('\$${result.amount.toStringAsFixed(2)} added!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: AppBar(
        backgroundColor: kSteamDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kSteamAccent),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('WALLET', style: GoogleFonts.rajdhani(color: kSteamAccent, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 3)),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [kSteamMed, kSteamDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    border: Border.all(color: kSteamAccent.withValues(alpha: 0.4), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.1), blurRadius: 20)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WALLET BALANCE', style: GoogleFonts.rajdhani(fontSize: 11, color: kSteamSubtext, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      Text(
                        '\$${_totalCredit.toStringAsFixed(2)}',
                        style: GoogleFonts.rajdhani(fontSize: 36, fontWeight: FontWeight.w800, color: kSteamGreen),
                      ),
                      const SizedBox(height: 4),
                      Text('Available to spend', style: GoogleFonts.rajdhani(fontSize: 12, color: kSteamSubtext)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const SteamSectionHeader('Payment Method'),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: kSteamDark, border: Border.all(color: kSteamMed), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      _radioTile('wallet', Icons.account_balance_wallet, 'Wallet Balance'),
                      Divider(color: kSteamMed, height: 1),
                      _radioTile('card', Icons.credit_card, 'Card Payment'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const SteamSectionHeader('Add Funds'),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                  children: [5, 10, 20, 50, 100, 500].map((amount) {
                    return GestureDetector(
                      onTap: () => _addFunds(amount.toDouble()),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kSteamDark,
                          border: Border.all(color: kSteamAccent.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.1), blurRadius: 6)],
                        ),
                        child: Center(
                          child: Text(
                            '\$$amount',
                            style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.w800, color: kSteamAccent),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                const SteamSectionHeader('Recent Transactions'),
                const SizedBox(height: 12),
                if (_transactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: kSteamDark, border: Border.all(color: kSteamMed), borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Text('No transactions yet', style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 14)),
                    ),
                  )
                else
                  ..._transactions.reversed.map((txn) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: kSteamDark, border: Border.all(color: kSteamMed), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(txn.type, style: GoogleFonts.rajdhani(fontSize: 13, fontWeight: FontWeight.w700, color: kSteamText)),
                              const SizedBox(height: 2),
                              Text(
                                txn.cardLast4 == 'wallet' ? 'Via Wallet' : 'Card: ****${txn.cardLast4}',
                                style: GoogleFonts.rajdhani(fontSize: 11, color: kSteamSubtext),
                              ),
                              Text(
                                '${txn.date.hour}:${txn.date.minute.toString().padLeft(2, '0')} · ${txn.date.month}/${txn.date.day}/${txn.date.year}',
                                style: GoogleFonts.rajdhani(fontSize: 10, color: kSteamSubtext),
                              ),
                            ],
                          ),
                          Text('+\$${txn.amount.toStringAsFixed(2)}', style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.w800, color: kSteamGreen)),
                        ],
                      ),
                    ),
                  )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: kSteamDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(color: kSteamBg, border: Border.all(color: kSteamMed), borderRadius: BorderRadius.circular(6)),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _navBtn(Icons.smart_toy, () => context.push('/chatbot')),
              const SizedBox(width: 10),
              _navBtn(Icons.person, () => context.push('/profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _radioTile(String value, IconData icon, String label) {
    final selected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? kSteamAccent : kSteamMed, width: 2),
              ),
              child: selected ? Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: kSteamAccent))) : null,
            ),
            const SizedBox(width: 12),
            Icon(icon, color: selected ? kSteamAccent : kSteamSubtext, size: 18),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.w700, color: selected ? kSteamText : kSteamSubtext)),
          ],
        ),
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
