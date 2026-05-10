import 'package:flutter/material.dart';
import 'package:zenno/widgets/gaming_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenno/src/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

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
                    Text('Admin access required',
                        style: GoogleFonts.rajdhani(color: kSteamRed, fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          );
        }
        return _buildDashboard(context, ref);
      },
      loading: () => _buildLoading(context),
      error: (e, s) => _buildDashboard(context, ref),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersStreamProvider);
    final gamesAsync = ref.watch(gamesStreamProvider);

    final users = usersAsync.maybeWhen(data: (u) => u, orElse: () => null);
    final gamesCount = gamesAsync.maybeWhen(data: (g) => g.length, orElse: () => null);

    final totalUsers = users?.length ?? 0;
    final activeUsers = users?.where((u) => (u['status'] ?? 'active') == 'active').length ?? 0;
    final suspendedUsers = users?.where((u) => u['status'] == 'suspended').length ?? 0;
    final bannedUsers = users?.where((u) => u['status'] == 'banned').length ?? 0;

    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: AppBar(
        backgroundColor: kSteamDark,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('ADMIN DASHBOARD',
            style: GoogleFonts.rajdhani(color: kSteamAccent, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 3)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: kSteamAccent),
            tooltip: 'Sign Out',
            onPressed: () async {
              ref.read(localAuthSessionProvider.notifier).state = null;
              try {
                await ref.read(authServiceProvider).signOut();
              } catch (_) {}
              if (context.mounted) context.go('/login');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.transparent, kSteamAccent, Colors.transparent])),
          ),
        ),
      ),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 8,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SteamSectionHeader('System Stats'),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _StatCard(
                          title: 'Total Users',
                          value: users == null ? '...' : '$totalUsers',
                          color: kSteamAccent,
                          icon: Icons.people),
                      _StatCard(
                          title: 'Total Games',
                          value: gamesCount == null ? '...' : '$gamesCount',
                          color: kSteamGreen,
                          icon: Icons.videogame_asset),
                      _StatCard(
                          title: 'Active',
                          value: users == null ? '...' : '$activeUsers',
                          color: Colors.greenAccent,
                          icon: Icons.check_circle_outline),
                      _StatCard(
                          title: 'Suspended / Banned',
                          value: users == null ? '...' : '${suspendedUsers + bannedUsers}',
                          color: Colors.orange,
                          icon: Icons.block),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const SteamSectionHeader('Admin Actions'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(
                      label: 'Manage Users',
                      onPressed: () => context.push('/admin-users'),
                      color: kSteamAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(
                      label: 'Manage Games',
                      onPressed: () => context.push('/admin-games'),
                      color: kSteamGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(
                      label: 'Manage Upcoming Games',
                      onPressed: () => context.push('/admin-upcoming-games'),
                      color: Colors.purpleAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(
                      label: 'Manage Notifications',
                      onPressed: () => context.push('/admin-notifications'),
                      color: Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(
                      label: 'Settings',
                      onPressed: () => context.push('/admin-settings'),
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: GamingAppBar(title: 'Admin Dashboard'),
      body: const GamingGradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: kSteamAccent),
              SizedBox(height: 16),
              Text('Checking access...', style: TextStyle(color: kSteamSubtext)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSteamDark,
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.rajdhani(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.rajdhani(fontSize: 11, color: kSteamSubtext)),
        ],
      ),
    );
  }
}
