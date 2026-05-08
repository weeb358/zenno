import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {'date': '2026-05-07', 'type': 'Purchase', 'amount': '-\$29.99', 'game': 'Cyber Nomad'},
      {'date': '2026-05-05', 'type': 'Wallet Top-up', 'amount': '+\$50.00', 'game': 'Credit'},
      {'date': '2026-05-01', 'type': 'Purchase', 'amount': '-\$19.99', 'game': 'Neon Racers'},
    ];

    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: GamingAppBar(title: 'TRANSACTION HISTORY'),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 8,
          child: SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final txn = transactions[index];
                final isIncome = txn['amount']!.startsWith('+');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kSteamDark,
                      border: Border.all(color: kSteamMed, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(txn['type']!, style: GoogleFonts.rajdhani(fontSize: 13, fontWeight: FontWeight.w700, color: kSteamText)),
                            const SizedBox(height: 4),
                            Text(txn['game']!, style: GoogleFonts.rajdhani(fontSize: 11, color: kSteamSubtext)),
                            const SizedBox(height: 2),
                            Text(txn['date']!, style: GoogleFonts.rajdhani(fontSize: 10, color: kSteamSubtext)),
                          ],
                        ),
                        Text(
                          txn['amount']!,
                          style: GoogleFonts.rajdhani(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isIncome ? kSteamGreen : kSteamRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
