import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';

class CardData {
  final String cardNumber;
  final String cvv;
  final String issueDate;
  final double amount;
  final DateTime timestamp;

  CardData({
    required this.cardNumber,
    required this.cvv,
    required this.issueDate,
    required this.amount,
    required this.timestamp,
  });
}

class CardPaymentScreen extends StatefulWidget {
  const CardPaymentScreen({super.key});

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  late TextEditingController _cardNumberController;
  late TextEditingController _cvvController;
  late TextEditingController _issueDateController;
  String _selectedCardType = 'credit';

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();
    _cvvController = TextEditingController();
    _issueDateController = TextEditingController();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cvvController.dispose();
    _issueDateController.dispose();
    super.dispose();
  }

  void _confirmPayment() {
    if (_cardNumberController.text.isEmpty || _cvvController.text.isEmpty || _issueDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all card details!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: kSteamDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: kSteamMed, width: 1)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kSteamRed, width: 2),
                  color: kSteamRed.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: kSteamRed, size: 28),
              ),
              const SizedBox(height: 14),
              Text('WARNING', style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.w800, color: kSteamRed, letterSpacing: 2)),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to proceed with this transaction? This action can\'t be undone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(fontSize: 13, color: kSteamText),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: kSteamMed, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(child: Text('CANCEL', style: GoogleFonts.rajdhani(fontSize: 12, fontWeight: FontWeight.w700, color: kSteamSubtext, letterSpacing: 1))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _processPayment();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: kSteamAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(child: Text('CONFIRM', style: GoogleFonts.rajdhani(fontSize: 12, fontWeight: FontWeight.w800, color: kSteamBg, letterSpacing: 1))),
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

  void _processPayment() {
    final cardData = CardData(
      cardNumber: _cardNumberController.text,
      cvv: _cvvController.text,
      issueDate: _issueDateController.text,
      amount: 0.0,
      timestamp: DateTime.now(),
    );
    Navigator.of(context).pop(cardData);
  }

  Widget _darkField(TextEditingController controller, String hint, {bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: kSteamDark,
        border: Border.all(color: kSteamMed, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _radioCard(String value, String label) {
    final selected = _selectedCardType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedCardType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: kSteamDark,
          border: Border.all(color: selected ? kSteamAccent : kSteamMed, width: selected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? kSteamAccent : kSteamSubtext, width: 2),
              ),
              child: selected
                  ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: kSteamAccent)))
                  : null,
            ),
            Text(label, style: GoogleFonts.rajdhani(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? kSteamAccent : kSteamText, letterSpacing: 0.5)),
          ],
        ),
      ),
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
        title: Text('WALLET PAYMENT', style: GoogleFonts.rajdhani(color: kSteamAccent, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 3)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, kSteamAccent, Colors.transparent]))),
        ),
      ),
      body: GamingGradientBackground(
        child: ParticleWidget(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SteamSectionHeader('Payment Method'),
                const SizedBox(height: 14),
                _radioCard('credit', 'CREDIT CARD'),
                const SizedBox(height: 8),
                _radioCard('debit', 'DEBIT CARD'),
                const SizedBox(height: 20),
                Text('CARD NUMBER', style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
                const SizedBox(height: 8),
                _darkField(_cardNumberController, 'XXXX XXXX XXXX XXXX'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CVV', style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          _darkField(_cvvController, 'XXX', obscure: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EXPIRY DATE', style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          _darkField(_issueDateController, 'MM/YY'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: GamingButton(label: 'CONFIRM PAYMENT', onPressed: _confirmPayment),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: kSteamDark, border: Border(top: BorderSide(color: kSteamMed, width: 1))),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              hintText: 'Search...',
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
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => context.push('/chatbot'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: kSteamMed, shape: BoxShape.circle, border: Border.all(color: kSteamAccent.withValues(alpha: 0.5))),
                    child: const Icon(Icons.smart_toy, color: kSteamAccent, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
