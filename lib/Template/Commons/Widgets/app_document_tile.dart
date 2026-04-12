import 'package:flutter/material.dart';
import '../Styles/style.dart';

class AppDocumentTile extends StatelessWidget {
  final String title;
  final String? subtitle1;
  final String? subtitle2;
  final String? trailing1;
  final String? trailing2;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailingWidget;

  const AppDocumentTile({
    super.key,
    required this.title,
    this.subtitle1,
    this.subtitle2,
    this.trailing1,
    this.trailing2,
    this.icon = Icons.edit_outlined,
    this.onTap,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: AppStyle.cardOf(context),
        child: Row(
          children: [
            // Icon section
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: cs.onSurface,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle1 != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle1!,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (subtitle2 != null)
                        Text(
                          subtitle2!,
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      const Spacer(),
                      if (trailing1 != null)
                        Text(
                          trailing1!,
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      if (trailing1 != null && trailing2 != null)
                        const SizedBox(width: 8),
                      if (trailing2 != null)
                        Text(
                          trailing2!,
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Trailing Widget
            if (trailingWidget != null) ...[
              const SizedBox(width: 8),
              trailingWidget!,
            ],
          ],
        ),
      ),
    );
  }
}
