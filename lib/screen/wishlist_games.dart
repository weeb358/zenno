import 'package:flutter/material.dart';
import '../widgets/gaming_widgets.dart';
import 'homescreen.dart';
import 'game_description.dart';

class WishlistGamesScreen extends StatefulWidget {
  const WishlistGamesScreen({super.key});

  @override
  State<WishlistGamesScreen> createState() => _WishlistGamesScreenState();
}

class _WishlistGamesScreenState extends State<WishlistGamesScreen> {
  final List<Map<String, String>> _wishlistGames = [
    {'name': 'Game 1', 'price': '\$29.99'},
    {'name': 'Game 2', 'price': '\$39.99'},
    {'name': 'Game 3', 'price': '\$49.99'},
    {'name': 'Game 4', 'price': '\$59.99'},
    {'name': 'Game 5', 'price': '\$34.99'},
    {'name': 'Game 6', 'price': '\$44.99'},
    {'name': 'Game 7', 'price': '\$54.99'},
    {'name': 'Game 8', 'price': '\$64.99'},
    {'name': 'Game 9', 'price': '\$24.99'},
    {'name': 'Game 10', 'price': '\$69.99'},
    {'name': 'Game 11', 'price': '\$79.99'},
    {'name': 'Game 12', 'price': '\$89.99'},
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
                        MaterialPageRoute(builder: (context) => const Homescreen()),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Color(0xFF2563EB), size: 28),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'GAMES WISHLIST',
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
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _wishlistGames.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameDescriptionScreen(
                                gameName: _wishlistGames[index]['name']!,
                                gamePrice: _wishlistGames[index]['price']!,
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
                                        _wishlistGames[index]['name']!
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
                                        _wishlistGames[index]['price']!,
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFF2563EB),
              width: 2,
            ),
          ),
          color: Color(0xFFFFFFFF),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF2563EB),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0xFFFAFAFA),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.search,
                        color: Color(0xFF2563EB),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Logo',
                            hintStyle: TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 12,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border(
                      top: BorderSide(color: Color(0xFF2563EB), width: 2),
                      bottom: BorderSide(color: Color(0xFF2563EB), width: 2),
                      left: BorderSide(color: Color(0xFF2563EB), width: 2),
                      right: BorderSide(color: Color(0xFF2563EB), width: 2),
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
