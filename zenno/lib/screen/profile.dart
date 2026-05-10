import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gaming_widgets.dart';
import '../src/providers.dart';
import '../src/translations.dart';
import 'auth/edit_profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(firebaseAuthProvider);
    final db = ref.read(realtimeDatabaseProvider);
    final user = auth.currentUser;
    if (user == null) return;

    try {
      await db.ref('users/${user.uid}').remove();
      await user.delete();
      ref.read(localAuthSessionProvider.notifier).state = null;
      if (context.mounted) context.go('/login');
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kSteamDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: kSteamRed),
        ),
        title: Text(tr('delete_account'), style: GoogleFonts.rajdhani(color: kSteamRed, fontWeight: FontWeight.w700, fontSize: 18)),
        content: Text(
          'This will permanently delete your account and all data. This cannot be undone.',
          style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.rajdhani(color: kSteamAccent)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAccount(context, ref);
            },
            child: Text('DELETE', style: GoogleFonts.rajdhani(color: kSteamRed, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);

    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: AppBar(
        backgroundColor: kSteamDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kSteamAccent),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          tr('profile'),
          style: GoogleFonts.rajdhani(color: kSteamAccent, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 3),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: kSteamAccent),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
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
          child: profileAsync.when(
            data: (profile) {
              final userName = (profile?['username'] ?? profile?['displayName'] ?? profile?['email'] ?? 'Gamer').toString();
              final userEmail = (profile?['email'] ?? '').toString();
              final userDescription = (profile?['description'] ?? '').toString();
              final role = (profile?['role'] ?? 'user').toString();
              final photoUrl = (profile?['photoURL'] ?? '').toString();
              final totalGames = (profile?['totalGames'] ?? 0).toString();
              final hoursPlayed = (profile?['hoursPlayed'] ?? 0).toString();

              Widget avatarChild;
              if (photoUrl.isNotEmpty) {
                avatarChild = ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    photoUrl,
                    width: 80, height: 80, fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(Icons.person, color: kSteamAccent, size: 40),
                  ),
                );
              } else {
                avatarChild = const Icon(Icons.person, color: kSteamAccent, size: 40);
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [kSteamDark, kSteamMed], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        border: Border.all(color: kSteamAccent.withValues(alpha: 0.3), width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.08), blurRadius: 16)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: kSteamMed,
                              border: Border.all(color: kSteamAccent, width: 2),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: avatarChild,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: role == 'admin' ? kSteamGreen.withValues(alpha: 0.2) : kSteamAccent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    role.toUpperCase(),
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 10, fontWeight: FontWeight.w800,
                                      color: role == 'admin' ? kSteamGreen : kSteamAccent,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(userName, style: GoogleFonts.rajdhani(fontSize: 18, fontWeight: FontWeight.w800, color: kSteamText)),
                                if (userEmail.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(userEmail, style: GoogleFonts.rajdhani(fontSize: 12, color: kSteamSubtext), overflow: TextOverflow.ellipsis),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats
                    Row(
                      children: [
                        Expanded(child: _StatBox(value: totalGames, label: tr('games_owned'), icon: Icons.sports_esports)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatBox(value: hoursPlayed, label: tr('hours_played'), icon: Icons.access_time)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Bio
                    SteamSectionHeader(tr('bio')),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kSteamDark,
                        border: Border.all(color: kSteamMed, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        userDescription.isEmpty ? tr('no_bio') : userDescription,
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          color: userDescription.isEmpty ? kSteamSubtext : kSteamText,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Delete account
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _showDeleteDialog(context, ref),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kSteamRed),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: Text(
                          tr('delete_account_btn'),
                          style: GoogleFonts.rajdhani(color: kSteamRed, fontWeight: FontWeight.w700, letterSpacing: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: kSteamAccent)),
            error: (e, _) => Center(child: Text('Error: $e', style: GoogleFonts.rajdhani(color: kSteamRed))),
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatBox({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSteamDark,
        border: Border.all(color: kSteamMed, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: kSteamAccent, size: 22),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.rajdhani(fontSize: 20, fontWeight: FontWeight.w800, color: kSteamText)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.rajdhani(fontSize: 11, color: kSteamSubtext)),
        ],
      ),
    );
  }
}
