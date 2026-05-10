import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';
import 'package:zenno/src/providers.dart';

class AdminNotificationsScreen extends ConsumerWidget {
  const AdminNotificationsScreen({super.key});

  static const _types = [
    {'label': 'New Release', 'value': 'new_release'},
    {'label': 'Sale / Offer', 'value': 'sale'},
    {'label': 'Wishlist Drop', 'value': 'wishlist'},
    {'label': 'Upcoming Game', 'value': 'upcoming'},
    {'label': 'Achievement', 'value': 'achievement'},
    {'label': 'Game Update', 'value': 'update'},
    {'label': 'General', 'value': 'general'},
  ];

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
    final notificationsAsync = ref.watch(notificationsStreamProvider);

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
          'MANAGE NOTIFICATIONS',
          style: GoogleFonts.rajdhani(
              color: kSteamAccent, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 3),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: kSteamAccent),
            tooltip: 'Send Notification',
            onPressed: () => _showAddDialog(context, ref),
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
          particleCount: 6,
          child: SafeArea(
            child: notificationsAsync.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_off, color: kSteamSubtext, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications yet — tap + to send one',
                          style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    final type = (n['type'] ?? 'general').toString();
                    final createdAt = n['createdAt'] as int? ?? 0;
                    final date = createdAt > 0
                        ? DateTime.fromMillisecondsSinceEpoch(createdAt)
                        : null;
                    final dateStr = date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : '';

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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        Text(dateStr,
                                            style: GoogleFonts.rajdhani(
                                                color: kSteamSubtext, fontSize: 11)),
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
                              IconButton(
                                icon: const Icon(Icons.close, color: kSteamRed, size: 20),
                                onPressed: () => _showDeleteDialog(
                                    context, ref, (n['id'] ?? '').toString(),
                                    (n['title'] ?? 'Notification').toString()),
                              ),
                            ],
                          ),
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

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedType = 'general';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: kSteamDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: kSteamAccent, width: 1.5),
          ),
          title: Text(
            'SEND NOTIFICATION',
            style: GoogleFonts.rajdhani(
                color: kSteamAccent, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(titleController, 'Title', Icons.title),
                const SizedBox(height: 12),
                _dialogField(descController, 'Description', Icons.notes, maxLines: 3),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: kSteamMed,
                    border: Border.all(color: kSteamAccent.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: kSteamDark,
                    icon: const Icon(Icons.arrow_drop_down, color: kSteamAccent),
                    items: _types.map((t) => DropdownMenuItem(
                      value: t['value'],
                      child: Text(t['label']!,
                          style: GoogleFonts.rajdhani(
                              color: kSteamText, fontSize: 13)),
                    )).toList(),
                    onChanged: (v) => setState(() => selectedType = v ?? 'general'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.rajdhani(
                      color: kSteamSubtext, fontWeight: FontWeight.w700)),
            ),
            TextButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final desc = descController.text.trim();
                if (title.isEmpty || desc.isEmpty) return;
                await ref.read(notificationServiceProvider).addNotification({
                  'title': title,
                  'description': desc,
                  'type': selectedType,
                });
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification sent')),
                  );
                }
              },
              child: Text('SEND',
                  style: GoogleFonts.rajdhani(
                      color: kSteamAccent, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, String id, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kSteamDark,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: kSteamRed),
            const SizedBox(width: 8),
            Text('Delete Notification',
                style: GoogleFonts.rajdhani(
                    color: kSteamRed, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Delete "$title"?\nThis action cannot be undone.',
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
              await ref.read(notificationServiceProvider).deleteNotification(id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification deleted')),
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

  static Widget _dialogField(
      TextEditingController controller, String hint, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
        prefixIcon: Icon(icon, color: kSteamAccent, size: 18),
        filled: true,
        fillColor: kSteamMed,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide:
              BorderSide(color: kSteamAccent.withValues(alpha: 0.4), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: kSteamAccent, width: 1.5),
        ),
      ),
    );
  }
}
