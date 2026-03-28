import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme_tokens.dart';

import '../../../providers/live_provider.dart';
import '../../../providers/profile_provider.dart';
import '../main_navigation_screen.dart';

class ProductivityPage extends StatefulWidget {
  const ProductivityPage({super.key});

  @override
  State<ProductivityPage> createState() => _ProductivityPageState();
}

class _ProductivityPageState extends State<ProductivityPage> {
  static const _primaryBlue = AppThemeTokens.blueEnd;
  static const _pageBg = AppThemeTokens.pageBackgroundWhite;
  String? _selectedFocus;
  final TextEditingController _goalsController = TextEditingController();

  static const _focusAreas = [
    'Coding',
    'Tech',
    'Finance',
    'Study',
    'Writing',
    'Business',
  ];

  @override
  void dispose() {
    _goalsController.dispose();
    super.dispose();
  }

  Future<void> _goLive() async {
    final didGoLive = await context.read<LiveProvider>().goLive(
      profile: context.read<ProfileProvider>().profile,
      intent: 'Productivity',
      tags: [_selectedFocus ?? 'Focus'],
    );

    if (!mounted) return;
    if (!didGoLive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please allow GPS/location permission to go live.'),
        ),
      );
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(initialIndex: 2),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _pageBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Productivity'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What are you working on today?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppThemeTokens.blueEnd,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'MAIN FOCUS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _focusAreas.map((focus) {
                  final isSelected = _selectedFocus == focus;
                  return FilterChip(
                    label: Text(focus),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedFocus = selected ? focus : null);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: _primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppThemeTokens.blueEnd,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? _primaryBlue
                          : const Color(0xFFE5E7EB),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'GOALS FOR THE DAY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _goalsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Building a luminous dashboard UI...',
                  hintStyle: const TextStyle(color: Color(0xFDD1D5DB)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [
                        AppThemeTokens.blueStart,
                        AppThemeTokens.blueEnd,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryBlue.withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _goLive,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Go Live',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.flash_on, color: Colors.white, size: 18),
                      ],
                    ),
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
