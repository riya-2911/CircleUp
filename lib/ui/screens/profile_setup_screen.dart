import 'dart:convert';

import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../../services/database_helper.dart';
import '../../services/prefs_helper.dart';
import 'main_navigation_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final Set<String> _selectedInterests = <String>{};
  final List<String> _allInterests = const [
    'AI',
    'Fitness',
    'Startups',
    'Travel',
    'Music',
    'Gaming',
    'Tech',
    'Design',
  ];

  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final userId = await PrefsHelper.getUserId();
    if (userId == null || userId.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    ProfileModel? existing;
    try {
      existing = await DatabaseHelper.instance.getUserProfile(userId);
    } catch (_) {
      final payload = await PrefsHelper.getProfilePayload();
      if (payload != null && payload.isNotEmpty) {
        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        existing = ProfileModel.fromMap(decoded);
      }
    }

    if (existing != null && mounted) {
      _nameController.text = existing.fullName;
      _collegeController.text = existing.collegeOrProfession;
      _bioController.text = existing.shortBio;
      _selectedInterests
        ..clear()
        ..addAll(existing.interests);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    final fullName = _nameController.text.trim();
    final college = _collegeController.text.trim();
    final bio = _bioController.text.trim();

    if (fullName.isEmpty) {
      _showMessage('Please enter your full name.');
      return;
    }
    if (college.isEmpty) {
      _showMessage('Please enter college or profession.');
      return;
    }
    if (_selectedInterests.length < 3) {
      _showMessage('Please select at least 3 interests.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      String? userId = await PrefsHelper.getUserId();
      userId ??= 'local_${DateTime.now().millisecondsSinceEpoch}';

      await PrefsHelper.saveUserId(userId);
      await PrefsHelper.saveUserName(fullName);

      final profile = ProfileModel(
        userId: userId,
        fullName: fullName,
        collegeOrProfession: college,
        shortBio: bio,
        interests: _selectedInterests.toList(),
        photoPath: null,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      try {
        await DatabaseHelper.instance.upsertUserProfile(profile);
      } catch (_) {
        // On platforms where sqflite plugin is unavailable, persist fallback payload.
      }
      await PrefsHelper.saveProfilePayload(jsonEncode(profile.toMap()));
      await PrefsHelper.setProfileSetupCompleted();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not save profile offline. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _collegeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF4F6FC);
    const primaryBlue = Color(0xFF2940FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Profile Setup'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Complete Your Profile',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              'Help the community get to know you better.',
                              style: TextStyle(color: Color(0xFF6B7280)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 38,
                                  backgroundColor: const Color(0xFFEAEFFB),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: primaryBlue.withOpacity(0.85),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text('Add Profile Photo', style: TextStyle(color: Color(0xFF6B7280))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _label('Full Name'),
                          _input(
                            controller: _nameController,
                            hint: 'Enter your name',
                          ),
                          const SizedBox(height: 12),
                          _label('College / Profession'),
                          _input(
                            controller: _collegeController,
                            hint: 'Where do you work or study?',
                          ),
                          const SizedBox(height: 12),
                          _label('Short Bio (Optional)'),
                          _input(
                            controller: _bioController,
                            hint: 'Tell us a bit about your journey...',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _label('Select Interests'),
                              const Text(
                                'Pick at least 3',
                                style: TextStyle(
                                  color: Color(0xFF2940FF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _allInterests.map((interest) {
                              final isSelected = _selectedInterests.contains(interest);
                              return FilterChip(
                                label: Text(interest),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedInterests.add(interest);
                                    } else {
                                      _selectedInterests.remove(interest);
                                    }
                                  });
                                },
                                selectedColor: primaryBlue,
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF111827),
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Continue'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: _isSaving
                                  ? null
                                  : () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const MainNavigationScreen(),
                                        ),
                                      ),
                              child: const Text('Skip For Now'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF2F4F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}