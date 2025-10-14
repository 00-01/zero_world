/// Quick Suggestion Chip Widget
/// 
/// Clickable suggestion chips for common actions

import 'package:flutter/material.dart';
import '../models/ai_chat.dart';

class QuickSuggestionChip extends StatelessWidget {
  final QuickSuggestion suggestion;
  final VoidCallback? onTap;

  const QuickSuggestionChip({
    super.key,
    required this.suggestion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light
              ? Colors.grey[100]
              : Colors.grey[800],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (suggestion.icon != null) ...[
              Text(
                suggestion.icon!,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              suggestion.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
