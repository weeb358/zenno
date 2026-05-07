import 'package:flutter/material.dart';
import '../widgets/gaming_widgets.dart';
import 'categories/action_games.dart';
import 'categories/horror_games.dart';
import 'categories/coops_games.dart';
import 'categories/sports_games.dart';
import 'upcoming_games.dart';
import 'wishlist_games.dart';
import 'notifications.dart';
import 'menu.dart';
import 'wallet.dart';
import 'profile.dart';
import 'game_description.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  String _selectedCategory = 'ACTION';
  int _currentSlide = 0;
  late PageController _pageController;
  final List<String> _categories = ['ACTION', 'HORROR', 'CO-OPS', 'SPORTS'];
  final List<Map<String, String>> _products = [
    {'name': 'Product 1', 'price': '\$29.99'},
    {'name': 'Product 2', 'price': '\$39.99'},
    {'name': 'Product 3', 'price': '\$49.99'},
    {'name': 'Product 4', 'price': '\$59.99'},
    {'name': 'Product 5', 'price': '\$34.99'},
    {'name': 'Product 6', 'price': '\$44.99'},
    {'name': 'Product 7', 'price': '\$54.99'},
    {'name': 'Product 8', 'price': '\$64.99'},
    {'name': 'Product 9', 'price': '\$24.99'},
    {'name': 'Product 10', 'price': '\$69.99'},
    {'name': 'Product 11', 'price': '\$79.99'},
    {'name': 'Product 12', 'price': '\$89.99'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories[0];
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
                // Top icons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.home, color: Color(0xFF2563EB), size: 28),
                    const SizedBox(width: 60),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      ),
                      child: const Icon(Icons.notifications, color: Color(0xFF2563EB), size: 28),
                    ),
                    const SizedBox(width: 60),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const UpcomingGamesScreen()),
                      ),
                      child: const Icon(Icons.dashboard, color: Color(0xFF2563EB), size: 28),
                    ),
                    const SizedBox(width: 80),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const MenuScreen()),
                      ),
                      child: const Icon(Icons.menu, color: Color(0xFF2563EB), size: 28),
                    ),
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
                // Category and buttons row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFF2563EB), width: 2),
                          bottom: BorderSide(color: Color(0xFF2563EB), width: 2),
                          left: BorderSide(color: Color(0xFF2563EB), width: 2),
                          right: BorderSide(color: Color(0xFF2563EB), width: 2),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x4D2563EB),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        dropdownColor: const Color(0xFFFAFAFA),
                        items: _categories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            // Navigate to appropriate category screen
                            Widget screen;
                            switch (newValue) {
                              case 'ACTION':
                                screen = const ActionGamesScreen();
                                break;
                              case 'HORROR':
                                screen = const HorrorGamesScreen();
                                break;
                              case 'CO-OPS':
                                screen = const CoOpsGamesScreen();
                                break;
                              case 'SPORTS':
                                screen = const SportsGamesScreen();
                                break;
                              default:
                                screen = const ActionGamesScreen();
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => screen),
                            );
                          }
                        },
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                        underline: const SizedBox(),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF2563EB),
                          size: 24,
                        ),
                        selectedItemBuilder: (BuildContext context) {
                          return _categories.map((String value) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              child: Text(
                                'CATEGORIES',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WishlistGamesScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF2563EB),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          shadowColor: const Color(0x4D2563EB),
                          backgroundColor: Colors.transparent,
                        ),
                        child: const Text(
                          'wishlist',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WalletScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF2563EB),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                        child: const Text(
                          'wallet',
                          style: TextStyle(
                            color: Color.fromARGB(255, 6, 99, 111),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Featured product section with slider
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
                            onTap: () {
                              Widget screen;
                              switch (_selectedCategory) {
                                case 'ACTION':
                                  screen = const ActionGamesScreen();
                                  break;
                                case 'HORROR':
                                  screen = const HorrorGamesScreen();
                                  break;
                                case 'CO-OPS':
                                  screen = const CoOpsGamesScreen();
                                  break;
                                case 'SPORTS':
                                  screen = const SportsGamesScreen();
                                  break;
                                default:
                                  screen = const ActionGamesScreen();
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => screen,
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 0),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Color(0xFF2563EB), width: 2),
                                  bottom: BorderSide(color: Color(0xFF2563EB), width: 2),
                                  left: BorderSide(color: Color(0xFF2563EB), width: 2),
                                  right: BorderSide(color: Color(0xFF2563EB), width: 2),
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(8)),
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
                            ),                            ),                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Carousel indicators
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
                // Product list
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          // Images box
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GameDescriptionScreen(
                                    gameName: _products[index]['name']!,
                                    gamePrice: _products[index]['price']!,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 90,
                              height: 70,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Color(0xFF2563EB), width: 2),
                                  bottom: BorderSide(color: Color(0xFF2563EB), width: 2),
                                  left: BorderSide(color: Color(0xFF2563EB), width: 2),
                                  right: BorderSide(color: Color(0xFF2563EB), width: 2),
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(6)),
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
                          ),
                          const SizedBox(width: 12),
                          // Details box
                          Expanded(
                            child: Container(
                              height: 70,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Color(0xFF2563EB), width: 2),
                                  bottom: BorderSide(color: Color(0xFF2563EB), width: 2),
                                  left: BorderSide(color: Color(0xFF2563EB), width: 2),
                                  right: BorderSide(color: Color(0xFF2563EB), width: 2),
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(6)),
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
                                          gameName: _products[index]['name']!,
                                          gamePrice: _products[index]['price']!,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _products[index]['name']!.toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFF2563EB),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _products[index]['price']!,
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
      // Gaming Bottom navigation with prominent search
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
              // Search bar (prominent)
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
                            hintText: 'Zenno Search',
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
              // Profile button (prominent)
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                ),
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