import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenno/src/providers.dart';
import 'package:go_router/go_router.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsersAsync = ref.watch(allUsersStreamProvider);

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
          'MANAGE USERS',
          style: GoogleFonts.rajdhani(color: kSteamAccent, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 3),
        ),
        centerTitle: true,
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
            child: allUsersAsync.when(
              data: (users) {
                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.group_off, color: kSteamSubtext, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'No users yet',
                          style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Users who sign up will appear here',
                          style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: users.length,
                  itemBuilder: (context, index) => _buildUserRow(context, users[index], ref),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: kSteamAccent)),
              error: (e, s) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.group_off, color: kSteamSubtext, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'No users yet',
                      style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Users who sign up will appear here',
                      style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserRow(BuildContext context, Map<String, dynamic> user, WidgetRef ref) {
    final displayName = (user['displayName'] ?? user['username'] ?? 'Unknown User').toString();
    final email = (user['email'] ?? 'No email').toString();
    final status = (user['status'] ?? 'active').toString();
    final uid = (user['uid'] ?? '').toString();
    final isBlocked = status == 'suspended' || status == 'banned';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kSteamDark,
          border: Border.all(color: isBlocked ? kSteamRed.withValues(alpha: 0.4) : kSteamMed, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isBlocked ? kSteamRed.withValues(alpha: 0.15) : kSteamMed,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                isBlocked ? Icons.block : Icons.person,
                color: isBlocked ? kSteamRed : kSteamAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    email,
                    style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isBlocked)
                    Text(
                      'BLOCKED',
                      style: GoogleFonts.rajdhani(color: kSteamRed, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _toggleBlock(context, uid, displayName, isBlocked, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: isBlocked ? kSteamGreen : Colors.orange, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isBlocked ? 'Unblock' : 'Block',
                  style: GoogleFonts.rajdhani(
                    color: isBlocked ? kSteamGreen : Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _showDeleteDialog(context, uid, displayName, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: kSteamRed, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Delete', style: GoogleFonts.rajdhani(color: kSteamRed, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleBlock(BuildContext context, String uid, String userName, bool isBlocked, WidgetRef ref) async {
    final newStatus = isBlocked ? 'active' : 'suspended';
    final action = isBlocked ? 'unblocked' : 'blocked';
    try {
      await ref.read(adminServiceProvider).updateUserStatus(uid, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$userName $action')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, String uid, String userName, WidgetRef ref) {
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
          'Delete $userName?\nThis action cannot be undone.',
          style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.rajdhani(color: kSteamSubtext, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(adminServiceProvider).deleteUser(uid);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$userName deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text('Delete', style: GoogleFonts.rajdhani(color: kSteamRed, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
