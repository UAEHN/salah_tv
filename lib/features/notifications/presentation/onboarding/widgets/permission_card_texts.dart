import 'package:flutter/material.dart';

/// Title + "مطلوب" label + description block used inside
/// [OnboardingPermissionCard]. Extracted so the parent stays under the
/// 150-line cap (CLAUDE.md §4).
class PermissionCardTexts extends StatelessWidget {
  final String title;
  final String description;
  final bool isRequired;

  const PermissionCardTexts({
    super.key,
    required this.title,
    required this.description,
    required this.isRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 8),
              Text(
                'مطلوب',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Text(
          description,
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.white.withValues(alpha: 0.6),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
