import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';
import 'package:zenno/src/providers.dart';

class AdminUpcomingGamesScreen extends ConsumerWidget {
  const AdminUpcomingGamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isUserAdminProvider);

    return isAdmin.when(
      data: (isAdminUser) {
        if (!isAdminUser) {
          return Scaffold(
            backgroundColor: kSteamBg,
            appBar: GamingAppBar(title: 'Access Denied'),
            body: const GamingGradientBackground(
              child: Center(child: Icon(Icons.lock, color: kSteamRed, size: 56)),
            ),
          );
        }
        return _buildScreen(context, ref);
      },
      loading: () => const Scaffold(
        backgroundColor: kSteamBg,
        body: Center(child: CircularProgressIndicator(color: kSteamAccent)),
      ),
      error: (e, s) => _buildScreen(context, ref),
    );
  }

  Widget _buildScreen(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingGamesStreamProvider);

    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: AppBar(
        backgroundColor: kSteamDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kSteamAccent),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'UPCOMING GAMES',
          style: GoogleFonts.rajdhani(
              color: kSteamAccent, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 3),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: kSteamAccent),
            tooltip: 'Add Upcoming Game',
            onPressed: () => context.push('/admin-add-upcoming-game'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.transparent, kSteamAccent, Colors.transparent]),
            ),
          ),
        ),
      ),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 8,
          child: SafeArea(
            child: upcomingAsync.when(
              data: (games) {
                if (games.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.videogame_asset_off,
                            color: kSteamSubtext, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'No upcoming games — tap + to add one',
                          style:
                              GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kSteamDark,
                          border: Border.all(color: kSteamMed, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 72,
                              decoration: const BoxDecoration(
                                color: kSteamMed,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                              child: const Icon(Icons.sports_esports,
                                  color: kSteamSubtext, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (game['name'] ?? 'Untitled').toString(),
                                      style: GoogleFonts.rajdhani(
                                          color: kSteamText,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      (game['releaseDate'] ?? '').toString(),
                                      style: GoogleFonts.rajdhani(
                                          color: kSteamSubtext, fontSize: 11),
                                    ),
                                    if ((game['price'] ?? '').toString().isNotEmpty)
                                      Text(
                                        (game['price'] ?? '').toString(),
                                        style: GoogleFonts.rajdhani(
                                            color: kSteamGreen,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showReleaseDialog(
                                context,
                                ref,
                                (game['id'] ?? '').toString(),
                                (game['name'] ?? 'Game').toString(),
                                game,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: kSteamGreen, width: 1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Release',
                                    style: GoogleFonts.rajdhani(
                                        color: kSteamGreen,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push(
                                '/admin-edit-upcoming-game/${(game['id'] ?? '').toString()}',
                                extra: game,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: kSteamAccent, width: 1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Edit',
                                    style: GoogleFonts.rajdhani(
                                        color: kSteamAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: kSteamRed, size: 20),
                              onPressed: () => _showDeleteDialog(
                                context,
                                ref,
                                (game['id'] ?? '').toString(),
                                (game['name'] ?? 'Game').toString(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator(color: kSteamAccent)),
              error: (e, s) => Center(
                child: Text('Error: $e',
                    style: GoogleFonts.rajdhani(color: kSteamRed, fontSize: 13)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showReleaseDialog(BuildContext context, WidgetRef ref, String id,
      String name, Map<String, dynamic> gameData) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kSteamDark,
        title: Row(
          children: [
            const Icon(Icons.rocket_launch, color: kSteamGreen),
            const SizedBox(width: 8),
            Text('Release to Store',
                style: GoogleFonts.rajdhani(
                    color: kSteamGreen, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Release "$name" to the live store?\n\nIt will appear in the games list and users can purchase it. It will be removed from upcoming games.',
          style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.rajdhani(
                    color: kSteamSubtext, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(gameServiceProvider).releaseUpcomingGame(id, gameData);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name released to the store!')),
                );
              }
            },
            child: Text('RELEASE',
                style: GoogleFonts.rajdhani(
                    color: kSteamGreen, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kSteamDark,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: kSteamRed),
            const SizedBox(width: 8),
            Text('Confirm Delete',
                style: GoogleFonts.rajdhani(
                    color: kSteamRed, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Delete "$name"?\nThis action cannot be undone.',
          style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.rajdhani(
                    color: kSteamSubtext, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(gameServiceProvider).deleteUpcomingGame(id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name deleted')),
                );
              }
            },
            child: Text('Delete',
                style: GoogleFonts.rajdhani(
                    color: kSteamRed, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
