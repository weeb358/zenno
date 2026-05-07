import 'package:flutter/material.dart';
import 'package:zenno/widgets/gaming_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenno/src/providers.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if user is admin
    final isAdmin = ref.watch(isUserAdminProvider);

    return isAdmin.when(
      data: (isAdminUser) {
        if (!isAdminUser) {
          return Scaffold(
            appBar: const GamingAppBar(title: 'ACCESS DENIED'),
            body: GamingGradientBackground(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'You do not have admin privileges',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Watch user statistics
        final userStats = ref.watch(userStatsProvider);

        return userStats.when(
          data: (stats) => _buildDashboard(context, stats),
          loading: () => _buildLoadingDashboard(context),
          error: (error, stack) => _buildErrorDashboard(context, error.toString()),
        );
      },
      loading: () => _buildLoadingDashboard(context),
      error: (error, stack) => _buildErrorDashboard(context, error.toString()),
    );
  }

  Widget _buildDashboard(BuildContext context, Map<String, dynamic> stats) {
    return Scaffold(
      appBar: const GamingAppBar(title: 'ADMIN DASHBOARD'),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 12,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SYSTEM STATS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _StatCard(
                        title: 'Total Users',
                        value: '${stats['totalUsers'] ?? 0}',
                        color: const Color(0xFF2563EB),
                      ),
                      _StatCard(
                        title: 'Active Users',
                        value: '${stats['activeUsers'] ?? 0}',
                        color: const Color(0xFF06B6D4),
                      ),
                      _StatCard(
                        title: 'Suspended',
                        value: '${stats['suspendedUsers'] ?? 0}',
                        color: const Color(0xFFFF6B6B),
                      ),
                      _StatCard(
                        title: 'Banned',
                        value: '${stats['bannedUsers'] ?? 0}',
                        color: const Color(0xFFFF6B6B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'ACTIONS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(
                      label: 'MANAGE USERS',
                      onPressed: () => context.push('/admin-users'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(
                      label: 'VIEW REPORTS',
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: GamingButton(
                      label: 'SYSTEM SETTINGS',
                      onPressed: () {},
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

    Widget _buildLoadingDashboard(BuildContext context) {
      return Scaffold(
        appBar: const GamingAppBar(title: 'ADMIN DASHBOARD'),
        body: GamingGradientBackground(
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF2563EB)),
          ),
        ),
      );
    }

    Widget _buildErrorDashboard(BuildContext context, String error) {
      return Scaffold(
        appBar: const GamingAppBar(title: 'ERROR'),
        body: GamingGradientBackground(
          child: Center(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.white),
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

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFAAAAAA),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
