import 'package:flutter/material.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class SearchGamesScreen extends StatefulWidget {
  const SearchGamesScreen({super.key});

  @override
  State<SearchGamesScreen> createState() => _SearchGamesScreenState();
}

class _SearchGamesScreenState extends State<SearchGamesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GamingAppBar(title: 'SEARCH GAMES'),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 8,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GamingTextField(
                    controller: _searchController,
                    hintText: 'SEARCH GAMES...',
                    prefixIcon: Icons.search,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2563EB), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Enter a game title to search...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
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
