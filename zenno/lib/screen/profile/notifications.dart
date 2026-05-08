import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _notifications = [
    {'title': 'Game Sale', 'message': 'Your wishlist game is 30% off!', 'time': '2 hours ago', 'icon': Icons.local_offer},
    {'title': 'Achievement', 'message': 'You unlocked a new trophy!', 'time': '1 day ago', 'icon': Icons.emoji_events},
    {'title': 'Friend Activity', 'message': 'Your friend started playing a game', 'time': '3 days ago', 'icon': Icons.people},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: GamingAppBar(title: 'NOTIFICATIONS'),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 8,
          child: SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kSteamDark,
                      border: Border.all(color: kSteamMed, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(color: kSteamMed, borderRadius: BorderRadius.circular(6)),
                          child: Icon(notif['icon'] as IconData, color: kSteamAccent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(notif['title'] as String, style: GoogleFonts.rajdhani(fontSize: 13, fontWeight: FontWeight.w700, color: kSteamText)),
                                  Text(notif['time'] as String, style: GoogleFonts.rajdhani(fontSize: 10, color: kSteamSubtext)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(notif['message'] as String, style: GoogleFonts.rajdhani(fontSize: 12, color: kSteamSubtext)),
                            ],
                          ),
                        ),
                      ],
                    ),
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
