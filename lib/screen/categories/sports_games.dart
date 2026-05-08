import 'package:flutter/material.dart';
import '../../widgets/gaming_widgets.dart';
import '../game_description.dart';
import '../../widgets/category_selector.dart';
import '../homescreen.dart';
import '../upcoming_games.dart';
import 'action_games.dart';
import 'horror_games.dart';
import 'coops_games.dart';

class SportsGamesScreen extends StatefulWidget {
  const SportsGamesScreen({super.key});

  @override
  State<SportsGamesScreen> createState() => _SportsGamesScreenState();
}

class _SportsGamesScreenState extends State<SportsGamesScreen> {
  late PageController _pageController;
  int _currentSlide = 0;

  final List<Map<String, String>> _games = [
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
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCategoryChange(String category) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          switch (category) {
            case 'ACTION':
              return const ActionGamesScreen();
            case 'HORROR':
              return const HorrorGamesScreen();
            case 'CO-OPS':
              return const CoOpsGamesScreen();
            default:
              return const SportsGamesScreen();
          }
        },
      ),
    );
  }

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const Homescreen()),
                      ),
                      child: const Icon(Icons.home,
                          color: Color(0xFF2563EB), size: 28),
                    ),
                    const SizedBox(width: 60),
                    const Icon(Icons.notifications,
                        color: Color(0xFF2563EB), size: 28),
                    const SizedBox(width: 60),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const UpcomingGamesScreen()),
                      ),
                      child: const Icon(Icons.dashboard,
                          color: Color(0xFF2563EB), size: 28),
                    ),
                    const SizedBox(width: 80),
                    const Icon(Icons.menu, color: Color(0xFF2563EB), size: 28),
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
                CategorySelector(
                  selectedCategory: 'SPORTS',
                  onCategoryChange: _onCategoryChange,
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'SPORTS GAMES',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentSlide = index;
                          });
                        },
                        children: List.generate(
                          4,
                          (index) => GestureDetector(
                            onTap: () {},
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 0),
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
                              child: Stack(
                                children: [
                                  const Center(
                                    child: Text(
                                      'Images',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Color(0xFF999999),
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    child: GamingButton(
                                      label: 'DETAILS',
                                      onPressed: () {},
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (index) => GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: _currentSlide == index ? 16 : 10,
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentSlide == index
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFBFDBFE),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _games.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 90,
                            height: 70,
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
                                  BorderRadius.all(Radius.circular(6)),
                              color: Color(0xFFF5F5F7),
                            ),
                            child: const Center(
                              child: Text(
                                'Images',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF999999),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 70,
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
                                    BorderRadius.all(Radius.circular(6)),
                                color: Color(0xFFF5F5F7),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GameDescriptionScreen(
                                          gameName: _games[index]['name']!,
                                          gamePrice: _games[index]['price']!,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _games[index]['name']!
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFF2563EB),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _games[index]['price']!,
                                          style: const TextStyle(
                                            color: Color(0xFF06B6D4),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
