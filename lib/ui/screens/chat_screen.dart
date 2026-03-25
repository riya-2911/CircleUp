import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock messages
    final messages = [
      {'sender': 'Jamie L.', 'text': 'Hey! Thanks for accepting. Looking forward to building the startup together!', 'isMe': false},
      {'sender': 'Me', 'text': 'Absolutely! What tech stack were you thinking of?', 'isMe': true},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jamie L.'),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Starting call...')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Starting video call...')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['isMe'] as bool;
                
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe ? theme.colorScheme.primary : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 16),
                      ),
                    ),
                    child: Text(
                      msg['text'] as String,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: theme.scaffoldBackgroundColor,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: theme.colorScheme.primary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
