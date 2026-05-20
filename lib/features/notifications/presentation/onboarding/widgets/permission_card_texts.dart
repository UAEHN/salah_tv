import 'package:flutter/material.dart';

/// Title + "مطلوب" badge + description block used inside
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
              const SizedBox(width: 6),
              const _RequiredBadge(),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.68),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _RequiredBadge extends StatelessWidget {
  const _RequiredBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'مطلوب',
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
