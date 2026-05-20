import 'package:flutter/material.dart';

/// Visual mock of the Adhan system notification the user will receive once
/// permissions are granted. Displayed at the top of the notification
/// onboarding screen — turns an abstract "permission" request into a
/// concrete promise of value (CLAUDE.md §4: stateless, declarative widget).
class MockAdhanNotificationPreview extends StatelessWidget {
  final bool isAcknowledged;
  const MockAdhanNotificationPreview({super.key, this.isAcknowledged = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAcknowledged
              ? Colors.green.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.18),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _AppBadge(),
          const SizedBox(width: 12),
          const Expanded(child: _NotificationBody()),
          const SizedBox(width: 8),
          const Text(
            'الآن',
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _AppBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE6B450), Color(0xFFB8862E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 22),
    );
  }
}

class _NotificationBody extends StatelessWidget {
  const _NotificationBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              'غسق',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(width: 6),
            Text('•', style: TextStyle(color: Colors.black45)),
            SizedBox(width: 6),
            Text(
              'صلاة الفجر',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
        SizedBox(height: 2),
        Text(
          'حان الآن وقت أذان الفجر 🕌',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
