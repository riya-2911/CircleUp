import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/intent_provider.dart';
import 'intent_pages/productivity_page.dart';
import 'intent_pages/hangout_page.dart';
import 'intent_pages/wellness_page.dart';
import 'intent_pages/travel_page.dart';
import 'intent_pages/fitness_page.dart';
import 'intent_pages/explore_page.dart';

class IntentSelectionPage extends StatefulWidget {
  const IntentSelectionPage({super.key});

  @override
  State<IntentSelectionPage> createState() => _IntentSelectionPageState();
}

class _IntentSelectionPageState extends State<IntentSelectionPage> {
  static const _primaryBlue = Color(0xFF5B46FF);
  static const _pageBg = Color(0xFFF7F8FC);
  String? _selectedId;

  static const _cards = <_IntentCardData>[
    _IntentCardData(
      id: 'productivity',
      title: 'Productivity',
      icon: Icons.work,
      color: Color(0xFF4F46E5),
    ),
    _IntentCardData(
      id: 'hangout',
      title: 'Hangout',
      icon: Icons.local_cafe,
      color: Color(0xFF6366F1),
    ),
    _IntentCardData(
      id: 'wellness',
      title: 'Wellness',
      icon: Icons.favorite,
      color: Color(0xFF6366F1),
    ),
    _IntentCardData(
      id: 'travel',
      title: 'Travel',
      icon: Icons.flight,
      color: Color(0xFF6366F1),
    ),
    _IntentCardData(
      id: 'fitness',
      title: 'Fitness',
      icon: Icons.fitness_center,
      color: Color(0xFF6366F1),
    ),
    _IntentCardData(
      id: 'explore',
      title: 'Explore',
      icon: Icons.public,
      color: Color(0xFF6366F1),
    ),
  ];

  @override
  void initState() {
    super.initState();
    final current = context.read<IntentProvider>().currentIntent;
    _selectedId = _mapProviderIntentId(current?.id);
  }

  Future<void> _submitIntent() async {
    if (_selectedId == null) return;

    final provider = context.read<IntentProvider>();
    final mappedProviderId = _mapScreenIntentToProviderId(_selectedId!);
    if (mappedProviderId != null) {
      final match = provider.availableIntents.where((intent) => intent.id == mappedProviderId);
      if (match.isNotEmpty) {
        await provider.selectIntent(match.first);
      }
    }

    if (!mounted) return;

    // Navigate to the respective intent page based on selection
    late Widget intentPage;
    switch (_selectedId) {
      case 'productivity':
        intentPage = const ProductivityPage();
        break;
      case 'hangout':
        intentPage = const HangoutPage();
        break;
      case 'wellness':
        intentPage = const WellnessPage();
        break;
      case 'travel':
        intentPage = const TravelPage();
        break;
      case 'fitness':
        intentPage = const FitnessPage();
        break;
      case 'explore':
        intentPage = const ExplorePage();
        break;
      default:
        return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => intentPage),
    );
  }

  String? _mapScreenIntentToProviderId(String screenId) {
    switch (screenId) {
      case 'productivity':
        return 'i1';
      case 'hangout':
        return 'i5';
      case 'fitness':
        return 'i3';
      case 'travel':
        return 'i4';
      default:
        return null;
    }
  }

  String? _mapProviderIntentId(String? providerId) {
    switch (providerId) {
      case 'i1':
        return 'productivity';
      case 'i5':
        return 'hangout';
      case 'i3':
        return 'fitness';
      case 'i4':
        return 'travel';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _pageBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFF111827),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 6, 16, 16 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Your Intent',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'What do you want to do right now?',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 10),
                  itemCount: _cards.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.86,
                  ),
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    final isSelected = card.id == _selectedId;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedId = card.id),
                      child: _IntentTile(
                        title: card.title,
                        icon: card.icon,
                        iconColor: card.color,
                        selected: isSelected,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      colors: _selectedId == null
                          ? const [Color(0xFFC4B5FD), Color(0xFFA78BFA)]
                          : const [Color(0xFF5B46FF), Color(0xFF7C3AED)],
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
                    onPressed: _selectedId == null ? null : _submitIntent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Set Intent',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
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

class _IntentCardData {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  const _IntentCardData({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}

class _IntentTile extends StatelessWidget {
  const _IntentTile({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.selected,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedContainer(
          width: double.infinity,
          height: double.infinity,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? const Color(0xFF5B46FF) : const Color(0xFFE5E7EB),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 23),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (selected)
          const Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              radius: 11,
              backgroundColor: Color(0xFF5B46FF),
              child: Icon(Icons.check, size: 12, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
