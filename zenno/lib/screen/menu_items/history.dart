import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/gaming_widgets.dart';
import '../menu.dart';
import '../game_description.dart';
import '../chat/chatbot.dart';

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
    {'name': 'Cyber Nomad', 'price': '\$29.99'},
    {'name': 'Shadow Realm', 'price': '\$39.99'},
    {'name': 'Neon Racers', 'price': '\$19.99'},
    {'name': 'Void Protocol', 'price': '\$49.99'},
  ];

  final List<WalletTransaction> _walletTransactions = [
    WalletTransaction(type: 'Card Added', amount: 50.00, date: DateTime(2026, 4, 26, 14, 30), cardLast4: '1234'),
    WalletTransaction(type: 'Card Added', amount: 100.00, date: DateTime(2026, 4, 25, 10, 15), cardLast4: '5678'),
    WalletTransaction(type: 'Card Added', amount: 25.00, date: DateTime(2026, 4, 24, 16, 45), cardLast4: '9012'),
  ];

  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: AppBar(
        backgroundColor: kSteamDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kSteamAccent),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MenuScreen()),
          ),
        ),
        title: Text(
          'HISTORY',
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
          particleCount: 8,
          child: Column(
            children: [
              // Tabs
              Container(
                color: kSteamDark,
                child: Row(
                  children: [
                    _tab('GAMES', 0),
                    _tab('WALLET', 1),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: _selectedTab == 0 ? _buildGamesTab() : _buildWalletTab(),
                ),
              ),
            ],
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
                              hintText: 'Search history...',
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
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen())),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kSteamMed,
                      shape: BoxShape.circle,
                      border: Border.all(color: kSteamAccent.withValues(alpha: 0.5)),
                    ),
                    child: const Icon(Icons.smart_toy, color: kSteamAccent, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kSteamMed,
                    shape: BoxShape.circle,
                    border: Border.all(color: kSteamAccent.withValues(alpha: 0.5)),
                  ),
                  child: const Icon(Icons.person, color: kSteamAccent, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(String label, int index) {
    final active = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: active ? kSteamAccent : kSteamMed, width: active ? 2 : 1),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? kSteamAccent : kSteamSubtext,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGamesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SteamSectionHeader('Purchased Games'),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _historyGames.length,
          itemBuilder: (context, index) {
            final game = _historyGames[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameDescriptionScreen(gameName: game['name']!, gamePrice: game['price']!),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: kSteamDark,
                    border: Border.all(color: kSteamMed, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 90,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: kSteamMed,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                        ),
                        child: const Icon(Icons.videogame_asset, color: kSteamSubtext, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                game['name']!.toUpperCase(),
                                style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 4),
                              Text(game['price']!, style: GoogleFonts.rajdhani(color: kSteamGreen, fontSize: 13, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: const Icon(Icons.chevron_right, color: kSteamSubtext, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWalletTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_walletTransactions.isNotEmpty) ...[
          const SteamSectionHeader('Last Transaction'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kSteamDark,
              border: Border.all(color: kSteamGreen.withValues(alpha: 0.6), width: 1.5),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: kSteamGreen.withValues(alpha: 0.1), blurRadius: 10)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_walletTransactions.first.type, style: GoogleFonts.rajdhani(fontSize: 12, fontWeight: FontWeight.w700, color: kSteamGreen)),
                    const SizedBox(height: 4),
                    Text('Card: •••• ${_walletTransactions.first.cardLast4}', style: GoogleFonts.rajdhani(fontSize: 11, color: kSteamSubtext)),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(_walletTransactions.first.date),
                      style: GoogleFonts.rajdhani(fontSize: 10, color: kSteamSubtext),
                    ),
                  ],
                ),
                Text(
                  '+\$${_walletTransactions.first.amount.toStringAsFixed(2)}',
                  style: GoogleFonts.rajdhani(fontSize: 18, fontWeight: FontWeight.w800, color: kSteamGreen),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        const SteamSectionHeader('All Transactions'),
        const SizedBox(height: 12),
        if (_walletTransactions.isEmpty)
          Center(
            child: Text('No transactions yet', style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13)),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _walletTransactions.length,
            itemBuilder: (context, index) {
              final txn = _walletTransactions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kSteamDark,
                    border: Border.all(color: kSteamMed, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(txn.type, style: GoogleFonts.rajdhani(fontSize: 12, fontWeight: FontWeight.w700, color: kSteamText)),
                            const SizedBox(height: 4),
                            Text('Card: •••• ${txn.cardLast4}', style: GoogleFonts.rajdhani(fontSize: 11, color: kSteamSubtext)),
                            Text(_formatDate(txn.date), style: GoogleFonts.rajdhani(fontSize: 10, color: kSteamSubtext)),
                          ],
                        ),
                      ),
                      Text(
                        '+\$${txn.amount.toStringAsFixed(2)}',
                        style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.w700, color: kSteamGreen),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.hour}:${d.minute.toString().padLeft(2, '0')} — ${d.month}/${d.day}/${d.year}';
}
