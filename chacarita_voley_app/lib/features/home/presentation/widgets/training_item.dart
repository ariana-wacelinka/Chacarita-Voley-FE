import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';

class TrainingItem extends StatelessWidget {
  final String category;
  final String subtitle;
  final String time;
  final String attendance;
  final VoidCallback? onTap;

  const TrainingItem({
    super.key,
    required this.category,
    required this.subtitle,
    required this.time,
    required this.attendance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.tokens.card1,
          border: Border.all(color: context.tokens.strokeToNoStroke, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context.tokens.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.tokens.placeholder,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final timeRow = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Symbols.schedule,
                      color: context.tokens.placeholder,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        time,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.tokens.text,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );

                final attendanceText = Text(
                  'Asistencia $attendance',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.tokens.placeholder,
                  ),
                );

                return Row(
                  children: [
                    Flexible(flex: 2, child: timeRow),
                    Expanded(
                      flex: 9,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: attendanceText,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
