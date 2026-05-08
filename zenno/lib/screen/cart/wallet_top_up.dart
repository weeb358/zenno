import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class WalletTopUpScreen extends StatefulWidget {
  const WalletTopUpScreen({super.key});

  @override
  State<WalletTopUpScreen> createState() => _WalletTopUpScreenState();
}

class _WalletTopUpScreenState extends State<WalletTopUpScreen> {
  final _amountController = TextEditingController();
  final List<double> quickAmounts = [10, 20, 50, 100];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: GamingAppBar(title: 'TOP UP WALLET'),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 8,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SteamSectionHeader('Enter Amount'),
                  const SizedBox(height: 12),
                  GamingTextField(
                    controller: _amountController,
                    hintText: '\$0.00',
                    prefixIcon: Icons.attach_money,
                  ),
                  const SizedBox(height: 28),
                  const SteamSectionHeader('Quick Select'),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: quickAmounts.length,
                    itemBuilder: (context, index) {
                      final amount = quickAmounts[index];
                      return GestureDetector(
                        onTap: () => setState(() => _amountController.text = amount.toStringAsFixed(2)),
                        child: Container(
                          decoration: BoxDecoration(
                            color: kSteamDark,
                            border: Border.all(color: kSteamAccent.withValues(alpha: 0.5), width: 1.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '\$${amount.toStringAsFixed(0)}',
                              style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(
                      label: 'ADD TO WALLET',
                      color: kSteamGreen,
                      onPressed: () {
                        if (_amountController.text.isEmpty) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added \$${_amountController.text} to wallet!')),
                        );
                      },
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
}
