import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final bool isImportant;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.title,
    required this.isImportant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: context.tokens.card2,
          border: Border.all(color: context.tokens.strokeToNoStroke, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: context.tokens.text),
        ),
      ),
    );
  }
}
