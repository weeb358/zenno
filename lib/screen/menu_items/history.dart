import 'package:flutter/material.dart';
import '../../widgets/gaming_widgets.dart';
import '../menu.dart';
import '../game_description.dart';

class WalletTransaction {
  final String type;
  final double amount;
  final DateTime date;
  final String cardLast4;

  WalletTransaction({
    required this.type,
    required this.amount,
    required this.date,
    required this.cardLast4,
  });
}

class HistoryGamesScreen extends StatefulWidget {
  const HistoryGamesScreen({super.key});

  @override
  State<HistoryGamesScreen> createState() => _HistoryGamesScreenState();
}

class _HistoryGamesScreenState extends State<HistoryGamesScreen> {
  final List<Map<String, String>> _historyGames = [
    {'name': 'Game 1', 'price': '\$29.99'},
    {'name': 'Game 2', 'price': '\$39.99'},
    {'name': 'Game 3', 'price': '\$49.99'},
    {'name': 'Game 4', 'price': '\$59.99'},
  ];

  final List<WalletTransaction> _walletTransactions = [
    WalletTransaction(
      type: 'Card Added',
      amount: 50.00,
      date: DateTime(2026, 4, 26, 14, 30),
      cardLast4: '1234',
    ),
    WalletTransaction(
      type: 'Card Added',
      amount: 100.00,
      date: DateTime(2026, 4, 25, 10, 15),
      cardLast4: '5678',
    ),
    WalletTransaction(
      type: 'Card Added',
      amount: 25.00,
      date: DateTime(2026, 4, 24, 16, 45),
      cardLast4: '9012',
    ),
  ];

  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const MenuScreen()),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Color(0xFF2563EB), size: 28),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'HISTORY',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 28),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 12,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tabs
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = 0;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTab == 0
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFCCCCCC),
                                width: _selectedTab == 0 ? 2 : 1,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'GAMES',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _selectedTab == 0
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF999999),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = 1;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTab == 1
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFCCCCCC),
                                width: _selectedTab == 1 ? 2 : 1,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'WALLET',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _selectedTab == 1
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF999999),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Content based on selected tab
                if (_selectedTab == 0) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'PURCHASED GAMES',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _historyGames.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GameDescriptionScreen(
                                  gameName: _historyGames[index]['name']!,
                                  gamePrice: _historyGames[index]['price']!,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    color: Color(0xFF2563EB), width: 2),
                                bottom: BorderSide(
                                    color: Color(0xFF2563EB), width: 2),
                                left: BorderSide(
                                    color: Color(0xFF2563EB), width: 2),
                                right: BorderSide(
                                    color: Color(0xFF2563EB), width: 2),
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              color: Color(0xFFF5F5F7),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 120,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF5F5F7),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Images',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF999999),
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _historyGames[index]['name']!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2563EB),
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _historyGames[index]['price']!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF06B6D4),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'TRANSACTION HISTORY',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Last Transaction
                  if (_walletTransactions.isNotEmpty) ...[
                    const Text(
                      'LAST TRANSACTION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF10B981),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        color: const Color(0xFFF0FDF4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _walletTransactions.first.type,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Card: ${_walletTransactions.first.cardLast4}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_walletTransactions.first.date.hour}:${_walletTransactions.first.date.minute.toString().padLeft(2, '0')} - ${_walletTransactions.first.date.month}/${_walletTransactions.first.date.day}/${_walletTransactions.first.date.year}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '+\$${_walletTransactions.first.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // All Transactions
                  const Text(
                    'ALL TRANSACTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_walletTransactions.isEmpty)
                    const Center(
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _walletTransactions.length,
                      itemBuilder: (context, index) {
                        final txn = _walletTransactions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF2563EB),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              color: const Color(0xFFFAFAFA),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        txn.type,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2563EB),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Card: ${txn.cardLast4}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF999999),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${txn.date.hour}:${txn.date.minute.toString().padLeft(2, '0')} - ${txn.date.month}/${txn.date.day}/${txn.date.year}',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Color(0xFF999999),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '+\$${txn.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
