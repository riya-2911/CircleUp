import 'package:flutter/material.dart';

class IntentCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const IntentCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? theme.colorScheme.primary : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
