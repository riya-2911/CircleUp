import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/intent_provider.dart';
import '../widgets/intent_card.dart';

class IntentSelectionScreen extends StatelessWidget {
  const IntentSelectionScreen({super.key});

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'menu_book':
        return Icons.menu_book;
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'flight_takeoff':
        return Icons.flight_takeoff;
      case 'local_cafe':
        return Icons.local_cafe;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final intentProvider = Provider.of<IntentProvider>(context);
    final intents = intentProvider.availableIntents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Intent'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'What are you looking for right now?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: intents.length,
                itemBuilder: (context, index) {
                  final intent = intents[index];
                  final isSelected = intentProvider.currentIntent?.id == intent.id;

                  return IntentCard(
                    title: intent.title,
                    description: intent.description,
                    icon: _getIconData(intent.iconName),
                    isSelected: isSelected,
                    onTap: () {
                      intentProvider.selectIntent(intent);
                      Navigator.pushNamed(context, '/discovery');
                    },
                  );
                },
              ),
            ),
            if (intentProvider.currentIntent != null)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to discovery
                    },
                    child: const Text('Start Connecting'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
