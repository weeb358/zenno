import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zenno/src/providers.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _usernameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _countryController = TextEditingController();

  bool _loaded = false;
  bool _isSaving = false;
  XFile? _selectedImage;
  String _currentPhotoUrl = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _descriptionController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    PermissionStatus status = await Permission.photos.request();
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    if (status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: kSteamDark,
            title: Text('Permission Required', style: GoogleFonts.rajdhani(color: kSteamAccent, fontWeight: FontWeight.w800)),
            content: Text('Enable photo access in device settings.', style: GoogleFonts.rajdhani(color: kSteamText)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.rajdhani(color: kSteamSubtext))),
              TextButton(onPressed: () { Navigator.pop(context); openAppSettings(); }, child: Text('Open Settings', style: GoogleFonts.rajdhani(color: kSteamAccent, fontWeight: FontWeight.w700))),
            ],
          ),
        );
      }
      return;
    }
    if (!status.isGranted) return;

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 512);
    if (picked != null && mounted) {
      setState(() => _selectedImage = picked);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final auth = ref.read(firebaseAuthProvider);
      final db = ref.read(realtimeDatabaseProvider);
      final user = auth.currentUser;
      if (user == null) throw Exception('Not signed in');

      String photoUrl = _currentPhotoUrl;
      if (_selectedImage != null) {
        final storageService = ref.read(storageServiceProvider);
        photoUrl = await storageService.uploadUserAvatar(File(_selectedImage!.path), user.uid);
      }

      final username = _usernameController.text.trim();
      await db.ref('users/${user.uid}').update({
        if (username.isNotEmpty) 'username': username,
        if (username.isNotEmpty) 'displayName': username,
        'description': _descriptionController.text.trim(),
        'country': _countryController.text.trim(),
        'photoURL': photoUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
  );

  Widget _darkField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: kSteamDark,
        border: Border.all(color: kSteamMed, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileStreamProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile != null && !_loaded) {
          _loaded = true;
          _usernameController.text = (profile['username'] ?? profile['displayName'] ?? '').toString();
          _descriptionController.text = (profile['description'] ?? '').toString();
          _countryController.text = (profile['country'] ?? '').toString();
          _currentPhotoUrl = (profile['photoURL'] ?? '').toString();
        }

        Widget avatarWidget;
        if (_selectedImage != null) {
          avatarWidget = ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(File(_selectedImage!.path), width: 88, height: 88, fit: BoxFit.cover),
          );
        } else if (_currentPhotoUrl.isNotEmpty) {
          avatarWidget = ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(_currentPhotoUrl, width: 88, height: 88, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(Icons.person, color: kSteamSubtext, size: 44),
            ),
          );
        } else {
          avatarWidget = const Icon(Icons.person, color: kSteamSubtext, size: 44);
        }

        return Scaffold(
          backgroundColor: kSteamBg,
          appBar: AppBar(
            backgroundColor: kSteamDark,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: kSteamAccent),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('EDIT PROFILE', style: GoogleFonts.rajdhani(color: kSteamAccent, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 3)),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, kSteamAccent, Colors.transparent]))),
            ),
          ),
          body: GamingGradientBackground(
            child: ParticleWidget(
              particleCount: 8,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: kSteamDark,
                                border: Border.all(color: _selectedImage != null ? kSteamGreen : kSteamAccent, width: 2),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.3), blurRadius: 16)],
                              ),
                              child: avatarWidget,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: kSteamAccent, width: 1.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _selectedImage != null ? 'PHOTO SELECTED ✓' : 'UPLOAD PHOTO',
                                style: GoogleFonts.rajdhani(
                                  color: _selectedImage != null ? kSteamGreen : kSteamAccent,
                                  fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _fieldLabel('USERNAME'),
                    _darkField(_usernameController, 'Enter username'),
                    const SizedBox(height: 16),
                    _fieldLabel('DESCRIPTION'),
                    _darkField(_descriptionController, 'Enter description', maxLines: 3),
                    const SizedBox(height: 16),
                    _fieldLabel('COUNTRY'),
                    _darkField(_countryController, 'Enter country'),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _isSaving
                          ? const Center(child: CircularProgressIndicator(color: kSteamAccent))
                          : GamingButton(label: 'Save Changes', onPressed: _saveProfile),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(backgroundColor: kSteamBg, body: Center(child: CircularProgressIndicator(color: kSteamAccent))),
      error: (e, _) => Scaffold(backgroundColor: kSteamBg, body: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red)))),
    );
  }
}
