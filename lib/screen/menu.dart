import 'package:flutter/material.dart';
import '../widgets/gaming_widgets.dart';
import 'homescreen.dart';
import 'notifications.dart';
import 'upcoming_games.dart';
import 'menu_items/library_games.dart';
import 'menu_items/history.dart';
import 'menu_items/support.dart';
import 'menu_items/settings.dart';
import 'menu_items/feedback.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.collections, 'label': 'Library'},
    {'icon': Icons.history, 'label': 'History'},
    {'icon': Icons.settings, 'label': 'Settings'},
    {'icon': Icons.help, 'label': 'Support'},
    {'icon': Icons.feedback, 'label': 'Feedback'},
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
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      ),
                      child: const Icon(Icons.notifications,
                          color: Color(0xFF2563EB), size: 28),
                    ),
                    const SizedBox(width: 60),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const UpcomingGamesScreen()),
                      ),
                      child: const Icon(Icons.dashboard,
                          color: Color(0xFF2563EB), size: 28),
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'MENU',
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
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () {
                          if (_menuItems[index]['label'] == 'Library') {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const LibraryGamesScreen()),
                            );
                          } else if (_menuItems[index]['label'] == 'History') {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const HistoryGamesScreen()),
                            );
                          } else if (_menuItems[index]['label'] == 'Support') {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const SupportScreen()),
                            );
                          } else if (_menuItems[index]['label'] == 'Settings') {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          } else if (_menuItems[index]['label'] == 'Feedback') {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Tapped: ${_menuItems[index]['label']}',
                                ),
                              ),
                            );
                          }
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
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF2563EB),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: const Color(0xFFFAFAFA),
                                  ),
                                  child: Icon(
                                    _menuItems[index]['icon'],
                                    color: const Color(0xFF2563EB),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  _menuItems[index]['label'],
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
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
