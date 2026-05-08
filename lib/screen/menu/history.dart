import 'package:flutter/material.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = [
      {'game': 'Game Title 1', 'date': '2025-05-07', 'action': 'Purchased'},
      {'game': 'Game Title 2', 'date': '2025-05-05', 'action': 'Downloaded'},
      {'game': 'Game Title 3', 'date': '2025-05-01', 'action': 'Played'},
    ];

    return Scaffold(
      appBar: const GamingAppBar(title: 'PURCHASE HISTORY'),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 10,
          child: SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
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
                            item['game']!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['date']!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                        ],
                      ),
                      Chip(
                        label: Text(
                          item['action']!,
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                        ),
                        backgroundColor: const Color(0xFF2563EB),
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
