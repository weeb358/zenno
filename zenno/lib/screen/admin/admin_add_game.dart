import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zenno/widgets/gaming_widgets.dart';
import 'package:zenno/src/providers.dart';

class AdminAddGameScreen extends ConsumerStatefulWidget {
  const AdminAddGameScreen({super.key});

  @override
  ConsumerState<AdminAddGameScreen> createState() => _AdminAddGameScreenState();
}

class _AdminAddGameScreenState extends ConsumerState<AdminAddGameScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _systemRequirementsController = TextEditingController();
  final _publishedDateController = TextEditingController();
  final _developerController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController(text: 'ACTION');
  final _bannerUrlController = TextEditingController();

  XFile? _selectedImage;
  bool _isUploading = false;
  int _discount = 0;
  String _currency = 'USD';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _systemRequirementsController.dispose();
    _publishedDateController.dispose();
    _developerController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _bannerUrlController.dispose();
    super.dispose();
  }

  static String _monthName(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }

  Future<void> _pickPublishedDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: kSteamAccent,
            surface: kSteamDark,
            onSurface: kSteamText,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: kSteamDark),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      _publishedDateController.text = '${picked.day} ${_monthName(picked.month)} ${picked.year}';
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);

    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      status = await Permission.photos.request();
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: kSteamDark,
            title: Text('Permission Required', style: GoogleFonts.rajdhani(color: kSteamAccent, fontWeight: FontWeight.w800)),
            content: Text(
              'Please enable ${source == ImageSource.camera ? 'camera' : 'photo library'} access in your device settings.',
              style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13),
            ),
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

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 1280);
    if (picked != null && mounted) {
      setState(() => _selectedImage = picked);
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSteamDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: kSteamMed, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Select Image', style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: kSteamAccent),
              title: Text('Choose from Gallery', style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 14, fontWeight: FontWeight.w600)),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: kSteamAccent),
              title: Text('Take a Photo', style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 14, fontWeight: FontWeight.w600)),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            if (_selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: kSteamRed),
                title: Text('Remove Image', style: GoogleFonts.rajdhani(color: kSteamRed, fontSize: 14, fontWeight: FontWeight.w600)),
                onTap: () { Navigator.pop(context); setState(() => _selectedImage = null); },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
  );

  Widget _darkField(TextEditingController controller, String hint, {int maxLines = 1, Widget? suffix}) {
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
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            title: Text('ADD GAME', style: GoogleFonts.rajdhani(color: kSteamAccent, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 3)),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, kSteamAccent, Colors.transparent]))),
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
                      // Banner picker
                      GestureDetector(
                        onTap: _showImagePickerSheet,
                        child: Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: kSteamDark,
                            border: Border.all(color: _selectedImage != null ? kSteamAccent : kSteamMed, width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _selectedImage != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                        child: Text('Tap to change', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 11)),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add_photo_alternate_outlined, color: kSteamAccent, size: 40),
                                    const SizedBox(height: 10),
                                    Text('Tap to Upload Game Banner', style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 13, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    Text('Gallery or Camera', style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 11)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _fieldLabel('GAME NAME'),
                      _darkField(_nameController, 'Enter game name'),
                      const SizedBox(height: 14),
                      _fieldLabel('DESCRIPTION'),
                      _darkField(_descriptionController, 'Enter description', maxLines: 3),
                      const SizedBox(height: 14),
                      _fieldLabel('SYSTEM REQUIREMENTS'),
                      _darkField(_systemRequirementsController, 'e.g. OS: Windows 10, RAM: 8GB, GPU: GTX 1060', maxLines: 4),
                      const SizedBox(height: 14),
                      _fieldLabel('PUBLISHED DATE'),
                      GestureDetector(
                        onTap: _pickPublishedDate,
                        child: AbsorbPointer(
                          child: _darkField(
                            _publishedDateController,
                            'Tap to select date',
                            suffix: const Icon(Icons.calendar_today, color: kSteamAccent, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _fieldLabel('DEVELOPER'),
                      _darkField(_developerController, 'Studio name'),
                      const SizedBox(height: 14),
                      _fieldLabel('PRICE & CURRENCY'),
                      Row(
                        children: [
                          Expanded(
                            child: _darkField(
                              _priceController,
                              _currency == 'USD' ? '29.99' : '4999',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: kSteamDark,
                              border: Border.all(color: kSteamMed, width: 1.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButton<String>(
                              value: _currency,
                              dropdownColor: kSteamDark,
                              underline: const SizedBox(),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              items: [
                                DropdownMenuItem(
                                  value: 'USD',
                                  child: Text('USD \$', style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                                DropdownMenuItem(
                                  value: 'PKR',
                                  child: Text('PKR Rs.', style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                              ],
                              onChanged: (v) => setState(() => _currency = v ?? 'USD'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _fieldLabel('CATEGORY'),
                      _darkField(_categoryController, 'ACTION'),
                      const SizedBox(height: 14),
                      _fieldLabel('BANNER URL (optional if image selected)'),
                      _darkField(_bannerUrlController, 'https://...'),
                      const SizedBox(height: 14),
                      _fieldLabel('DISCOUNT — $_discount%'),
                      Row(
                        children: [
                          Text('0%', style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 11)),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: kSteamAccent,
                                inactiveTrackColor: kSteamMed,
                                thumbColor: kSteamAccent,
                                overlayColor: kSteamAccent.withValues(alpha: 0.2),
                              ),
                              child: Slider(
                                value: _discount.toDouble(),
                                min: 0,
                                max: 80,
                                divisions: 16,
                                onChanged: (v) => setState(() => _discount = v.toInt()),
                              ),
                            ),
                          ),
                          Text('80%', style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: _isUploading
                            ? const Center(child: CircularProgressIndicator(color: kSteamAccent))
                            : GamingButton(
                                label: 'Add Game',
                                color: kSteamGreen,
                                onPressed: () async {
                                  final name = _nameController.text.trim();
                                  if (name.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Game name is required')));
                                    return;
                                  }
                                  setState(() => _isUploading = true);
                                  try {
                                    String bannerUrl = _bannerUrlController.text.trim();
                                    if (_selectedImage != null) {
                                      final storageService = ref.read(storageServiceProvider);
                                      final tempId = '${name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
                                      bannerUrl = await storageService.uploadGameBanner(File(_selectedImage!.path), tempId);
                                    }
                                    await ref.read(gameServiceProvider).addGame({
                                      'name': name,
                                      'description': _descriptionController.text.trim(),
                                      'systemRequirements': _systemRequirementsController.text.trim(),
                                      'publishedDate': _publishedDateController.text.trim(),
                                      'developer': _developerController.text.trim(),
                                      'price': _priceController.text.trim(),
                                      'currency': _currency,
                                      'category': _categoryController.text.trim(),
                                      'bannerUrl': bannerUrl,
                                      'status': 'active',
                                      'discount': _discount,
                                    });
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Game added successfully')));
                                      context.pop();
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add game: $e')));
                                    }
                                  } finally {
                                    if (mounted) setState(() => _isUploading = false);
                                  }
                                },
                              ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(backgroundColor: kSteamBg, body: Center(child: CircularProgressIndicator(color: kSteamAccent))),
      error: (e, s) => Scaffold(backgroundColor: kSteamBg, body: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red)))),
    );
  }
}
