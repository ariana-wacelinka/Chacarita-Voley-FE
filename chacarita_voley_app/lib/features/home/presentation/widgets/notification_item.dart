import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isImportant;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.isImportant,
    this.onTap,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.tokens.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.tokens.text.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
