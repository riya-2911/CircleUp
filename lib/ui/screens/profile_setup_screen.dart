import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import 'main_navigation_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  String _selectedGender = 'Male';
  int _selectedAge = 24;
  String _selectedPersonality = 'Extrovery';
  String _selectedRole = 'Student';
  String? _selectedPhotoPath;

  final Set<String> _selectedInterests = <String>{};
  final List<String> _allInterests = const [
    'AI',
    'Startups',
    'Fitness',
    'Travel',
    'Music',
    'Gaming',
    'Tech',
  ];

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _personalityOptions = ['Introvery', 'Extrovery', 'Ambiverts'];
  final List<String> _roleOptions = ['Student', 'Professional'];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final profileProvider = context.read<ProfileProvider>();
    await profileProvider.loadProfile();

    if (profileProvider.hasProfile && mounted) {
      _nameController.text = profileProvider.fullName;
      _selectedGender = profileProvider.gender;
      _selectedAge = profileProvider.age;
      _selectedPersonality = profileProvider.personality;
      _cityController.text = profileProvider.city;
      if (_roleOptions.contains(profileProvider.collegeOrProfession)) {
        _selectedRole = profileProvider.collegeOrProfession;
      }
      _selectedInterests.addAll(profileProvider.interests);
      _selectedPhotoPath = profileProvider.photoPath;
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          _selectedPhotoPath = image.path;
        });
      }
    } catch (e) {
      _showMessage('Error picking image: $e');
    }
  }

  Future<void> _saveProfile() async {
    final fullName = _nameController.text.trim();
    final city = _cityController.text.trim();

    if (fullName.isEmpty) {
      _showMessage('Please enter your full name.');
      return;
    }
    if (city.isEmpty) {
      _showMessage('Please enter your city/area.');
      return;
    }
    if (_selectedInterests.length < 3) {
      _showMessage('Please select at least 3 interests.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.saveProfile(
        fullName: fullName,
        gender: _selectedGender,
        age: _selectedAge,
        personality: _selectedPersonality,
        city: city,
        collegeOrProfession: _selectedRole,
        interests: _selectedInterests.toList(),
        photoPath: _selectedPhotoPath,
      );

      if (!mounted) return;
      _showMessage('Profile saved successfully!', isSuccess: true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const MainNavigationScreen(initialIndex: 0),
            ),
            (route) => false,
          );
        }
      });
    } catch (e) {
      _showMessage('Unable to save profile right now. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF4F6FC);
    const primaryBlue = Color(0xFF5B46FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CircleUp',
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Profile Photo
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _selectedPhotoPath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                File(_selectedPhotoPath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person_outline,
                              size: 40,
                              color: Color(0xFFA5B4FC),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Full Name
              _buildLabel('FULL NAME'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: 'e.g. Alex Rivera',
              ),
              const SizedBox(height: 16),
              // Gender, Age, Personality Row
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('GENDER'),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _selectedGender,
                          items: _genderOptions,
                          onChanged: (value) {
                            setState(() => _selectedGender = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('AGE'),
                        const SizedBox(height: 8),
                        Column(
                          children: [
                            _buildTextField(
                              controller: null,
                              readOnly: true,
                              hint: _selectedAge.toString(),
                            ),
                            Slider(
                              value: _selectedAge.toDouble(),
                              min: 18,
                              max: 65,
                              divisions: 47,
                              onChanged: (value) {
                                setState(() => _selectedAge = value.toInt());
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('PERSONALITY'),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _selectedPersonality,
                          items: _personalityOptions,
                          onChanged: (value) {
                            setState(() => _selectedPersonality = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // City / Area
              _buildLabel('CITY / AREA'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _cityController,
                hint: 'San Francisco, CA',
              ),
              const SizedBox(height: 16),
              // Select Interests
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel('SELECT INTERESTS'),
                  Text(
                    '${_selectedInterests.length} SELECTED',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allInterests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedInterests.remove(interest);
                        } else {
                          _selectedInterests.add(interest);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF6B7280),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Student / Professional
              _buildLabel('COLLEGE / PROFESSION'),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedRole,
                items: _roleOptions,
                onChanged: (value) {
                  setState(() => _selectedRole = value!);
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'Your profile information is used to help you find the most relevant Circles.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 24),
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Continue ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: Color(0xFF6B7280),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String hint,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF5B46FF), width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(item),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
      ),
    );
  }
}