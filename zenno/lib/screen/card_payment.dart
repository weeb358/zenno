import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';
import '../src/providers.dart';

class AddCardScreen extends ConsumerStatefulWidget {
  const AddCardScreen({super.key});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String get _last4 {
    final n = _numberController.text.replaceAll(RegExp(r'\D'), '');
    return n.length >= 4 ? n.substring(n.length - 4) : ''.padLeft(4, '*');
  }

  Future<void> _saveCard() async {
    final name = _nameController.text.trim();
    final number = _numberController.text.replaceAll(RegExp(r'\D'), '');
    final expiry = _expiryController.text.trim();
    final cvv = _cvvController.text.trim();

    if (name.isEmpty || number.length < 16 || expiry.isEmpty || cvv.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all details. Card number must be 16 digits.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(userDataServiceProvider).saveCard({
        'cardholderName': name,
        'cardLast4': number.substring(number.length - 4),
        'expiry': expiry,
        'type': 'credit',
      });

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          backgroundColor: kSteamDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: kSteamGreen, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kSteamGreen.withValues(alpha: 0.15),
                    border: Border.all(color: kSteamGreen, width: 2),
                  ),
                  child: const Icon(Icons.credit_card,
                      color: kSteamGreen, size: 34),
                ),
                const SizedBox(height: 18),
                Text(
                  'CARD ADDED!',
                  style: GoogleFonts.rajdhani(
                      color: kSteamGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                Text(
                  'Card ending in ${number.substring(number.length - 4)} has been saved to your wallet.',
                  textAlign: TextAlign.center,
                  style:
                      GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GamingButton(
                    label: 'DONE',
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                    color: kSteamGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _cardPreview() {
    final name = _nameController.text.trim().isEmpty
        ? 'CARDHOLDER NAME'
        : _nameController.text.trim().toUpperCase();
    final expiry = _expiryController.text.trim().isEmpty
        ? 'MM/YY'
        : _expiryController.text.trim();
    final l4 = _last4.isEmpty ? '****' : _last4;

    return Container(
      width: double.infinity,
      height: 185,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1a237e), Color(0xFF283593)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: kSteamAccent.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CREDIT',
                  style: GoogleFonts.rajdhani(
                      color: Colors.white54, fontSize: 11, letterSpacing: 2)),
              const Icon(Icons.wifi, color: Colors.white38, size: 18),
            ],
          ),
          const Spacer(),
          Text(
            '**** **** **** $l4',
            style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontSize: 19,
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
                          color: Colors.white38, fontSize: 8, letterSpacing: 1)),
                  Text(name,
                      style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('EXPIRES',
                      style: GoogleFonts.rajdhani(
                          color: Colors.white38, fontSize: 8, letterSpacing: 1)),
                  Text(expiry,
                      style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Text(text,
            style: GoogleFonts.rajdhani(
                color: kSteamAccent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
      );

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    bool obscure = false,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kSteamBg,
        border: Border.all(color: kSteamMed, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        inputFormatters: formatters,
        onChanged: (_) => setState(() {}),
        style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        title: Text('ADD CARD',
            style: GoogleFonts.rajdhani(
                color: kSteamAccent,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 3)),
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
            ])),
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
                _cardPreview(),
                const SizedBox(height: 28),

                _label('CARDHOLDER NAME'),
                _field(_nameController, 'John Doe'),
                const SizedBox(height: 14),

                _label('CARD NUMBER'),
                _field(
                  _numberController,
                  '0000 0000 0000 0000',
                  keyboard: TextInputType.number,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CardNumberFormatter(),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('EXPIRY DATE'),
                          _field(
                            _expiryController,
                            'MM/YY',
                            keyboard: TextInputType.number,
                            formatters: [_ExpiryFormatter()],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('CVV'),
                          _field(
                            _cvvController,
                            '•••',
                            obscure: true,
                            keyboard: TextInputType.number,
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: _saving
                      ? const Center(
                          child:
                              CircularProgressIndicator(color: kSteamAccent))
                      : GamingButton(
                          label: 'SAVE CARD',
                          onPressed: _saveCard,
                          color: kSteamGreen,
                        ),
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

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // newValue is already digits-only (FilteringTextInputFormatter runs first)
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 16) digits = digits.substring(0, 16);
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
      composing: TextRange.empty,
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
      composing: TextRange.empty,
    );
  }
}
