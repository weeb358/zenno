import 'package:flutter/material.dart';
import 'package:zenno/widgets/gaming_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _userNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _emailController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: '');
    _descriptionController = TextEditingController(
      text: '',
    );
    _emailController = TextEditingController(text: '');
    _countryController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back,
                          color: Color(0xFF2563EB), size: 28),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'EDIT PROFILE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 28),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: GamingGradientBackground(
        child: ParticleWidget(
          particleCount: 12,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Profile Picture Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF2563EB),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFF5F5F7),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF2563EB),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          color: const Color(0xFFFFFFFF),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            color: Color(0xFF999999),
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Get Profile Picture',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF999999),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile picture upload feature coming soon!'),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF2563EB),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            color: const Color(0xFFFAFAFA),
                          ),
                          child: const Text(
                            'Upload Profile Picture',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // UserName Field
                const Text(
                  'UserName',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF2563EB),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    color: const Color(0xFFFAFAFA),
                  ),
                  child: TextField(
                    controller: _userNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter username',
                      hintStyle: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Description Field
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF2563EB),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    color: const Color(0xFFFAFAFA),
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter description',
                      hintStyle: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Email Field
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF2563EB),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    color: const Color(0xFFFAFAFA),
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter email',
                      hintStyle: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Country Field
                const Text(
                  'Country',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF2563EB),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    color: const Color(0xFFFAFAFA),
                  ),
                  child: TextField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      hintText: 'Enter country',
                      hintStyle: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Save Changes Button
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Changes saved successfully!'),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF2563EB),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        color: const Color(0xFFFAFAFA),
                      ),
                      child: const Center(
                        child: Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFF2563EB),
              width: 2,
            ),
          ),
          color: Color(0xFFFFFFFF),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF2563EB),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0xFFFAFAFA),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.search,
                        color: Color(0xFF2563EB),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Logo',
                            hintStyle: TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 12,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border(
                      top: BorderSide(color: Color(0xFF2563EB), width: 2),
                      bottom: BorderSide(color: Color(0xFF2563EB), width: 2),
                      left: BorderSide(color: Color(0xFF2563EB), width: 2),
                      right: BorderSide(color: Color(0xFF2563EB), width: 2),
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
