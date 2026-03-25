import 'package:flutter/material.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock incoming requests
    final requests = [
      {'name': 'Alex M.', 'message': 'Want to study together?', 'time': '2 mins ago'},
      {'name': 'Jamie L.', 'message': 'Can I join your startup group?', 'time': '15 mins ago'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Requests'),
      ),
      body: requests.isEmpty
          ? const Center(child: Text('No active requests.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final req = requests[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                              child: Text(
                                req['name']![0],
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                req['name']!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Text(
                              req['time']!,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '"${req['message']}"',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                // Request Reject mock
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request Rejected')));
                              },
                              child: const Text('Decline', style: TextStyle(color: Colors.red)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                // Request Accept mock
                                Navigator.pushNamed(context, '/chat');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Accept'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
