/// Action Card Widget
/// 
/// Interactive cards displayed in AI responses

import 'package:flutter/material.dart';
import '../models/ai_chat.dart';

class ActionCardWidget extends StatelessWidget {
  final ActionCard card;
  final Function(CardAction action)? onActionTap;

  const ActionCardWidget({
    super.key,
    required this.card,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: card.actions.isNotEmpty && onActionTap != null
            ? () => onActionTap!(card.actions.first)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (card.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    card.imageUrl!,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 120,
                      color: Colors.grey[300],
                      child: Icon(Icons.image, size: 48, color: Colors.grey[500]),
                    ),
                  ),
                ),
              
              if (card.imageUrl != null) const SizedBox(height: 12),

              // Title
              Text(
                card.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Subtitle
              if (card.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  card.subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],

              // Actions
              if (card.actions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: card.actions.map((action) {
                    return _buildActionButton(action, theme);
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(CardAction action, ThemeData theme) {
    return ElevatedButton(
      onPressed: onActionTap != null ? () => onActionTap!(action) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(action.label),
    );
  }
}
