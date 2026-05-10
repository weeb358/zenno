import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';
import '../src/providers.dart';
import 'homescreen.dart';
import 'upcoming_games.dart';
import 'menu.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static IconData _iconForType(String type) {
    switch (type) {
      case 'new_release': return Icons.new_releases;
      case 'sale': return Icons.local_offer;
      case 'wishlist': return Icons.trending_down;
      case 'upcoming': return Icons.calendar_today;
      case 'achievement': return Icons.emoji_events;
      case 'update': return Icons.system_update;
      default: return Icons.notifications;
    }
  }

  static String _timeAgo(int? createdAt) {
    if (createdAt == null || createdAt == 0) return '';
    final diff = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(createdAt));
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: kSteamDark,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _navIcon(context, Icons.home_rounded, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Homescreen()))),
                    _navIcon(context, Icons.notifications_rounded, null, active: true),
                    _navIcon(context, Icons.grid_view_rounded, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UpcomingGamesScreen()))),
                    _navIcon(context, Icons.menu_rounded, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MenuScreen()))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 6,
          child: notificationsAsync.when(
            data: (notifications) {
              if (notifications.isEmpty) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SteamSectionHeader('Notifications'),
                      const SizedBox(height: 60),
                      Center(
                        child: Column(
                          children: [
                            const Icon(Icons.notifications_off,
                                color: kSteamSubtext, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications yet',
                              style: GoogleFonts.rajdhani(
                                  color: kSteamSubtext, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SteamSectionHeader('Notifications'),
                    const SizedBox(height: 16),
                    ...notifications.map((n) {
                      final type = (n['type'] ?? 'general').toString();
                      final timeStr = _timeAgo(n['createdAt'] as int?);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: kSteamDark,
                            border: Border.all(color: kSteamMed, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: kSteamMed,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(_iconForType(type),
                                      color: kSteamAccent, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              (n['title'] ?? '').toString(),
                                              style: GoogleFonts.rajdhani(
                                                  color: kSteamText,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(timeStr,
                                              style: GoogleFonts.rajdhani(
                                                  color: kSteamSubtext,
                                                  fontSize: 11)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        (n['description'] ?? '').toString(),
                                        style: GoogleFonts.rajdhani(
                                            color: kSteamSubtext, fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
            loading: () => const Center(
                child: CircularProgressIndicator(color: kSteamAccent)),
            error: (e, s) => Center(
              child: Text('Error: $e',
                  style: GoogleFonts.rajdhani(color: kSteamRed, fontSize: 13)),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _navIcon(BuildContext context, IconData icon, VoidCallback? onTap, {bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? kSteamMed : Colors.transparent,
          border: active ? Border.all(color: kSteamAccent.withValues(alpha: 0.4), width: 1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: active ? kSteamAccent : kSteamSubtext, size: 22),
      ),
    );
  }
}
