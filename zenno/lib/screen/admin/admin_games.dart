import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';
import 'package:zenno/src/widgets/fade_in.dart';
import 'package:zenno/src/providers.dart';

class AdminGamesScreen extends ConsumerWidget {
  const AdminGamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isUserAdminProvider);

    return isAdmin.when(
      data: (isAdminUser) {
        if (!isAdminUser) {
          return Scaffold(
            backgroundColor: kSteamBg,
            appBar: GamingAppBar(title: 'Access Denied'),
            body: GamingGradientBackground(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, color: kSteamRed, size: 56),
                    const SizedBox(height: 16),
                    Text('Admin access required', style: GoogleFonts.rajdhani(color: kSteamRed, fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          );
        }

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
              'MANAGE GAMES',
              style: GoogleFonts.rajdhani(color: kSteamAccent, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 3),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: kSteamAccent),
                onPressed: () => context.push('/admin-add-game'),
                tooltip: 'Add Game',
              ),
            ],
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
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ref.watch(gamesStreamProvider).when(
                        data: (games) {
                          if (games.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.videogame_asset_off, color: kSteamSubtext, size: 48),
                                  const SizedBox(height: 16),
                                  Text('No games yet — tap + to add one', style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 14)),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: games.length,
                            itemBuilder: (context, index) {
                              final game = games[index];
                              return FadeIn(
                                index: index,
                                child: _GameRow(
                                  gameName: (game['name'] ?? 'Untitled Game').toString(),
                                  category: (game['category'] ?? 'General').toString(),
                                  price: (game['price'] ?? '').toString(),
                                  onDetails: () => context.push('/admin-edit-game/${game['id']}'),
                                  onDelete: () => _showDeleteDialog(context, ref, (game['id'] ?? '').toString(), (game['name'] ?? 'Untitled Game').toString()),
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator(color: kSteamAccent)),
                        error: (e, s) => Center(
                          child: Text('Error: $e', style: GoogleFonts.rajdhani(color: kSteamRed, fontSize: 13)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(backgroundColor: kSteamBg, body: Center(child: CircularProgressIndicator(color: kSteamAccent))),
      error: (e, s) => Scaffold(backgroundColor: kSteamBg, body: Center(child: Text('Error: $e', style: TextStyle(color: kSteamRed)))),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String gameId, String gameName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kSteamDark,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: kSteamRed),
            const SizedBox(width: 8),
            Text('Confirm Delete', style: GoogleFonts.rajdhani(color: kSteamRed, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Delete "$gameName"?\nThis action cannot be undone.',
          style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.rajdhani(color: kSteamSubtext, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(gameServiceProvider).deleteGame(gameId);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$gameName deleted')));
              }
            },
            child: Text('Delete', style: GoogleFonts.rajdhani(color: kSteamRed, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _GameRow extends StatelessWidget {
  final String gameName;
  final String category;
  final String price;
  final VoidCallback onDetails;
  final VoidCallback onDelete;

  const _GameRow({
    required this.gameName,
    required this.category,
    required this.price,
    required this.onDetails,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
              ),
              child: const Icon(Icons.videogame_asset, color: kSteamSubtext, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gameName, style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(category, style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 11)),
                    if (price.isNotEmpty)
                      Text(price, style: GoogleFonts.rajdhani(color: kSteamGreen, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: onDetails,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: kSteamAccent, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Edit', style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: kSteamRed, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
