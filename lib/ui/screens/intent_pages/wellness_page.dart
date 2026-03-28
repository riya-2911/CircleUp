import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/live_provider.dart';
import '../../../providers/profile_provider.dart';
import '../main_navigation_screen.dart';

class WellnessPage extends StatefulWidget {
  const WellnessPage({super.key});

  @override
  State<WellnessPage> createState() => _WellnessPageState();
}

class _WellnessPageState extends State<WellnessPage> {
  static const _primaryBlue = Color(0xFF5B46FF);
  static const _pageBg = Color(0xFFF7F8FC);
  String? _selectedActivity;
  String? _selectedMood;

  static const _activities = ['Yoga', 'Meditation', 'Reading', 'Walking', 'Workout'];
  static const _moods = ['Relaxed', 'Motivated', 'Mindful', 'Peaceful'];

  Future<void> _goLive() async {
    final didGoLive = await context.read<LiveProvider>().goLive(
      profile: context.read<ProfileProvider>().profile,
      intent: 'Wellness',
      tags: [_selectedActivity ?? 'Activity', _selectedMood ?? 'Mood'],
    );

    if (!mounted) return;
    if (!didGoLive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please allow GPS/location permission to go live.')),
      );
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen(initialIndex: 2)),
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
        title: const Text('Wellness'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Take care of yourself today',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'WELLNESS ACTIVITY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
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
                      setState(() => _selectedActivity = selected ? activity : null);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: _primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF374151),
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: isSelected ? _primaryBlue : const Color(0xFFE5E7EB),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              const Text(
                'YOUR MOOD',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _moods.map((mood) {
                  final isSelected = _selectedMood == mood;
                  return FilterChip(
                    label: Text(mood),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedMood = selected ? mood : null);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: _primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF374151),
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: isSelected ? _primaryBlue : const Color(0xFFE5E7EB),
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
                      colors: [Color(0xFF5B46FF), Color(0xFF7C3AED)],
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
