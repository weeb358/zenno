import 'package:flutter/material.dart';
import '../../widgets/gaming_widgets.dart';
import '../menu.dart';
import '../game_description.dart';

class LibraryGamesScreen extends StatefulWidget {
  const LibraryGamesScreen({super.key});

  @override
  State<LibraryGamesScreen> createState() => _LibraryGamesScreenState();
}

class _LibraryGamesScreenState extends State<LibraryGamesScreen> {
  final List<Map<String, String>> _libraryGames = [
    {'name': 'Game 1', 'price': '\$29.99'},
    {'name': 'Game 2', 'price': '\$39.99'},
    {'name': 'Game 3', 'price': '\$49.99'},
    {'name': 'Game 4', 'price': '\$59.99'},
  ];

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
                        'GAMES LIBRARY',
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'GAMES LIBRARY',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _libraryGames.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameDescriptionScreen(
                                gameName: _libraryGames[index]['name']!,
                                gamePrice: _libraryGames[index]['price']!,
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
                                        _libraryGames[index]['name']!
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Color(0xFF2563EB),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _libraryGames[index]['price']!,
                                        style: const TextStyle(
                                          color: Color(0xFF06B6D4),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 6),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0xFF2563EB),
                                            width: 1.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Details',
                                          style: TextStyle(
                                            color: Color(0xFF2563EB),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.3,
                                          ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
