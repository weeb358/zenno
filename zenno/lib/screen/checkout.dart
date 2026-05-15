// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';
import '../src/providers.dart';
import '../src/services/encryption_service.dart';
import 'checkout_success.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String gameName;
  final String gamePrice;

  const CheckoutScreen({
    super.key,
    required this.gameName,
    required this.gamePrice,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late TextEditingController _nameController;
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryController;
  late TextEditingController _secretCodeController;

  bool _isCardPayment = true;
  String _encryptedCardPreview = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _cardNumberController = TextEditingController();
    _expiryController = TextEditingController();
    _secretCodeController = TextEditingController();

    _cardNumberController.addListener(() {
      final raw = _cardNumberController.text.trim();
      setState(() {
        _encryptedCardPreview = raw.isNotEmpty ? EncryptionService.encryptText(raw) : '';
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _secretCodeController.dispose();
    super.dispose();
  }

  void _confirmPayment() {
    if (_isCardPayment) {
      if (_nameController.text.isEmpty ||
          _cardNumberController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _secretCodeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all card details!')),
        );
        return;
      }
    }

    final encrypted = _isCardPayment
        ? EncryptionService.encryptText(_cardNumberController.text.trim())
        : '';
    final masked = _isCardPayment
        ? EncryptionService.maskCardNumber(_cardNumberController.text.trim())
        : '';

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
                  color: kSteamRed.withValues(alpha: 0.15),
                  border: Border.all(color: kSteamRed, width: 1.5),
                ),
                child: const Center(child: Icon(Icons.warning_amber_rounded, color: kSteamRed, size: 28)),
              ),
              const SizedBox(height: 14),
              Text('CONFIRM PURCHASE', style: GoogleFonts.rajdhani(fontSize: 16, fontWeight: FontWeight.w800, color: kSteamText, letterSpacing: 1)),
              const SizedBox(height: 8),
              Text(
                'Buy "${widget.gameName}" for ${widget.gamePrice}?',
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(fontSize: 13, color: kSteamSubtext),
              ),
              if (_isCardPayment && encrypted.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kSteamBg,
                    border: Border.all(color: kSteamAccent.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock, color: kSteamAccent, size: 12),
                          const SizedBox(width: 4),
                          Text('AES-256 ENCRYPTED', style: GoogleFonts.rajdhani(fontSize: 10, fontWeight: FontWeight.w800, color: kSteamAccent, letterSpacing: 1)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Card: $masked', style: GoogleFonts.rajdhani(fontSize: 11, color: kSteamText)),
                      const SizedBox(height: 2),
                      Text(
                        'Hash: ${encrypted.length > 28 ? '${encrypted.substring(0, 28)}…' : encrypted}',
                        style: GoogleFonts.rajdhani(fontSize: 10, color: kSteamSubtext),
                      ),
                    ],
                  ),
                ),
              ],
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
                      child: Text('CANCEL', style: GoogleFonts.rajdhani(color: kSteamSubtext, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _processPayment();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSteamAccent,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text('CONFIRM', style: GoogleFonts.rajdhani(color: kSteamBg, fontWeight: FontWeight.w800)),
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

  Future<void> _processPayment() async {
    final userDataService = ref.read(userDataServiceProvider);
    await userDataService.savePurchase(widget.gameName, widget.gamePrice);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.gameName} purchased!')),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => CheckoutSuccessScreen(gameName: widget.gameName)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    final walletBalance = profileAsync.maybeWhen(
      data: (p) => (p?['wallet'] ?? 0.0),
      orElse: () => 0.0,
    );

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
          'CHECKOUT',
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
          particleCount: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order summary
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [kSteamMed, kSteamDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    border: Border.all(color: kSteamAccent.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(color: kSteamBg, borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.sports_esports, color: kSteamAccent, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.gameName, style: GoogleFonts.rajdhani(color: kSteamText, fontWeight: FontWeight.w800, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(widget.gamePrice, style: GoogleFonts.rajdhani(color: kSteamGreen, fontWeight: FontWeight.w800, fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Payment method
                const SteamSectionHeader('Payment Method'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kSteamDark,
                    border: Border.all(color: kSteamMed),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _radioOption(true, Icons.credit_card, 'Card Payment'),
                      const SizedBox(height: 10),
                      _radioOption(false, Icons.account_balance_wallet, 'Wallet Payment'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_isCardPayment) ...[
                  const SteamSectionHeader('Card Details'),
                  const SizedBox(height: 12),

                  _fieldLabel('NAME ON CARD'),
                  const SizedBox(height: 6),
                  _buildField(_nameController, hint: 'John Doe'),
                  const SizedBox(height: 14),

                  _fieldLabel('CARD NUMBER'),
                  const SizedBox(height: 6),
                  _buildField(_cardNumberController, hint: '0000-0000-0000-0000'),
                  if (_encryptedCardPreview.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: kSteamBg,
                        border: Border.all(color: kSteamAccent.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock, color: kSteamAccent, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Encrypted: ${_encryptedCardPreview.length > 30 ? '${_encryptedCardPreview.substring(0, 30)}…' : _encryptedCardPreview}',
                              style: GoogleFonts.rajdhani(fontSize: 11, color: kSteamAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('EXPIRY DATE'),
                            const SizedBox(height: 6),
                            _buildField(_expiryController, hint: 'MM/YY'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('CVV'),
                            const SizedBox(height: 6),
                            _buildField(_secretCodeController, obscure: true, hint: '•••'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kSteamDark,
                      border: Border.all(color: kSteamMed),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WALLET BALANCE', style: GoogleFonts.rajdhani(fontSize: 11, color: kSteamSubtext, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Text(
                          '\$${walletBalance.toStringAsFixed(2)}',
                          style: GoogleFonts.rajdhani(fontSize: 22, fontWeight: FontWeight.w800, color: kSteamGreen),
                        ),
                        const SizedBox(height: 6),
                        Text('Your wallet will be charged for this transaction.', style: GoogleFonts.rajdhani(fontSize: 12, color: kSteamSubtext)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Total
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
                      Text('TOTAL', style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.w700, color: kSteamSubtext, letterSpacing: 1)),
                      Text(widget.gamePrice, style: GoogleFonts.rajdhani(fontSize: 20, fontWeight: FontWeight.w800, color: kSteamGreen)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: GamingButton(
                    label: 'Confirm Payment',
                    onPressed: _confirmPayment,
                    color: kSteamGreen,
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

  Widget _radioOption(bool value, IconData icon, String label) {
    return GestureDetector(
      onTap: () => setState(() => _isCardPayment = value),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _isCardPayment == value ? kSteamAccent : kSteamMed, width: 2),
            ),
            child: _isCardPayment == value
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: kSteamAccent),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Icon(icon, color: _isCardPayment == value ? kSteamAccent : kSteamSubtext, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _isCardPayment == value ? kSteamText : kSteamSubtext,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(text, style: GoogleFonts.rajdhani(fontSize: 11, fontWeight: FontWeight.w700, color: kSteamSubtext, letterSpacing: 1));
  }

  Widget _buildField(TextEditingController controller, {String? hint, bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
        filled: true,
        fillColor: kSteamBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kSteamMed)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kSteamMed)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kSteamAccent, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
