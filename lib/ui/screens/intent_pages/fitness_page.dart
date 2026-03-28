import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme_tokens.dart';

import '../../../providers/live_provider.dart';
import '../../../providers/profile_provider.dart';
import '../main_navigation_screen.dart';

class FitnessPage extends StatefulWidget {
  const FitnessPage({super.key});

  @override
  State<FitnessPage> createState() => _FitnessPageState();
}

class _FitnessPageState extends State<FitnessPage> {
  static const _primaryBlue = AppThemeTokens.blueEnd;
  static const _pageBg = AppThemeTokens.pageBackgroundWhite;
  String? _selectedActivity;
  String? _selectedLevel;
  String? _selectedTime;

  static const _activities = ['Gym', 'Cardio', 'Yoga', 'Running', 'Sports'];
  static const _levels = ['Beginner', 'Intermediate', 'Advanced'];
  static const _times = ['Morning', 'Evening'];

  Future<void> _goLive() async {
    final didGoLive = await context.read<LiveProvider>().goLive(
      profile: context.read<ProfileProvider>().profile,
      intent: 'Fitness',
      tags: [
        _selectedActivity ?? 'Activity',
        _selectedLevel ?? 'Level',
        _selectedTime ?? 'Anytime',
      ],
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
        title: const Text('Fitness'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Train with someone nearby',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppThemeTokens.blueEnd,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'CHOOSE ACTIVITY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _activities.map((activity) {
                  final isSelected = _selectedActivity == activity;
                  return FilterChip(
                    label: Text(activity),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(
                        () => _selectedActivity = selected ? activity : null,
                      );
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
              const SizedBox(height: 28),
              const Text(
                'EXPERIENCE LEVEL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _levels.map((level) {
                  final isSelected = _selectedLevel == level;
                  return FilterChip(
                    label: Text(level),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedLevel = selected ? level : null);
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
              const SizedBox(height: 28),
              const Text(
                'TIME AVAILABILITY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _times.map((time) {
                  final isSelected = _selectedTime == time;
                  return FilterChip(
                    label: Text(time),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedTime = selected ? time : null);
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
