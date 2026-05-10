import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenno/widgets/gaming_widgets.dart';
import 'package:zenno/src/providers.dart';

class AdminAddUpcomingGameScreen extends ConsumerStatefulWidget {
  final String? gameId;
  final Map<String, dynamic>? existingData;

  const AdminAddUpcomingGameScreen({super.key, this.gameId, this.existingData});

  @override
  ConsumerState<AdminAddUpcomingGameScreen> createState() =>
      _AdminAddUpcomingGameScreenState();
}

class _AdminAddUpcomingGameScreenState
    extends ConsumerState<AdminAddUpcomingGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _releaseDateController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedCategory = 'ACTION';
  static const _categories = ['ACTION', 'HORROR', 'CO-OPS', 'SPORTS'];

  bool _isLoading = false;
  bool get _isEditing => widget.gameId != null;

  @override
  void initState() {
    super.initState();
    final d = widget.existingData;
    if (d != null) {
      _nameController.text = (d['name'] ?? '').toString();
      _priceController.text = (d['price'] ?? '').toString();
      _releaseDateController.text = (d['releaseDate'] ?? '').toString();
      _descController.text = (d['description'] ?? '').toString();
      final cat = (d['category'] ?? 'ACTION').toString().toUpperCase();
      _selectedCategory = _categories.contains(cat) ? cat : 'ACTION';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _releaseDateController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'name': _nameController.text.trim(),
      'price': _priceController.text.trim(),
      'releaseDate': _releaseDateController.text.trim(),
      'description': _descController.text.trim(),
      'category': _selectedCategory,
    };

    try {
      final service = ref.read(gameServiceProvider);
      if (_isEditing) {
        await service.updateUpcomingGame(widget.gameId!, data);
      } else {
        await service.addUpcomingGame(data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_isEditing
                ? 'Game updated successfully'
                : 'Upcoming game added')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          _isEditing ? 'EDIT UPCOMING GAME' : 'ADD UPCOMING GAME',
          style: GoogleFonts.rajdhani(
              color: kSteamAccent,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: 3),
        ),
        centerTitle: true,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField(
                    controller: _nameController,
                    hint: 'GAME NAME',
                    icon: Icons.sports_esports,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _priceController,
                    hint: 'PRICE (e.g. \$29.99)',
                    icon: Icons.attach_money,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Price is required' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _releaseDateController,
                    hint: 'RELEASE DATE (e.g. Jun 2026)',
                    icon: Icons.calendar_today,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Release date is required' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _descController,
                    hint: 'DESCRIPTION',
                    icon: Icons.notes,
                    maxLines: 4,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Description is required' : null,
                  ),
                  const SizedBox(height: 14),
                  // Category dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: kSteamDark,
                      border: Border.all(color: kSteamMed, width: 1.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.category, color: kSteamAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            underline: const SizedBox(),
                            dropdownColor: kSteamDark,
                            icon: const Icon(Icons.arrow_drop_down, color: kSteamAccent),
                            items: _categories
                                .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c,
                                          style: GoogleFonts.rajdhani(
                                              fontSize: 13, color: kSteamText)),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedCategory = v ?? 'ACTION'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: kSteamAccent))
                        : ElevatedButton(
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kSteamAccent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              elevation: 0,
                            ),
                            child: Text(
                              _isEditing ? 'UPDATE GAME' : 'ADD GAME',
                              style: GoogleFonts.rajdhani(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2),
                            ),
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

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
        prefixIcon: Icon(icon, color: kSteamAccent, size: 20),
        filled: true,
        fillColor: kSteamDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: kSteamMed, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: kSteamAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: kSteamRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: kSteamRed, width: 1.5),
        ),
        errorStyle:
            GoogleFonts.rajdhani(color: kSteamRed, fontSize: 11),
      ),
    );
  }
}
