import 'package:flutter/material.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {'date': '2025-05-07', 'type': 'Purchase', 'amount': '-\$29.99', 'game': 'Game Title 1'},
      {'date': '2025-05-05', 'type': 'Wallet Top-up', 'amount': '+\$50.00', 'game': 'Credit'},
      {'date': '2025-05-01', 'type': 'Purchase', 'amount': '-\$19.99', 'game': 'Game Title 2'},
    ];

    return Scaffold(
      appBar: const GamingAppBar(title: 'TRANSACTION HISTORY'),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 10,
          child: SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final txn = transactions[index];
                final isIncome = txn['amount']!.startsWith('+');
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF2563EB), width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            txn['type']!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            txn['game']!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            txn['date']!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        txn['amount']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isIncome ? const Color(0xFF10B981) : const Color(0xFFFF6B6B),
                        ),
                      ),
                    ],
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
