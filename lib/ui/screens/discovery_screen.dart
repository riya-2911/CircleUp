import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/intent_provider.dart';

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final intentProvider = Provider.of<IntentProvider>(context);
    final intent = intentProvider.currentIntent;

    if (intent == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Discover')),
        body: const Center(child: Text('Please select an intent first.')),
      );
    }

    final theme = Theme.of(context);

    // Mock data for nearby users
    final nearbyUsers = [
      {'name': 'Alex M.', 'distance': '0.5 km away', 'matchScore': '98%', 'status': 'Looking for a study group'},
      {'name': 'Jamie L.', 'distance': '1.2 km away', 'matchScore': '85%', 'status': 'Prepping for finals'},
      {'name': 'Chris P.', 'distance': '2.4 km away', 'matchScore': '72%', 'status': 'Coffee shop studying'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(intent.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: theme.colorScheme.primary.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.insights, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '18 people nearby are also looking to ${intent.title.toLowerCase()} right now.',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: nearbyUsers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = nearbyUsers[index];
                return Card(
                  elevation: 0,
                  color: theme.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                          child: Text(
                            user['name']![0],
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    user['name']!,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      user['matchScore']!,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(user['status']!, style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(user['distance']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  const Spacer(),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection Request Sent!')));
                                    },
                                    icon: const Icon(Icons.send, size: 14),
                                    label: const Text('Connect', style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
