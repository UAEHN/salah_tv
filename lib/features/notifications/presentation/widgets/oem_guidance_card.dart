import 'package:flutter/material.dart';

import '../../domain/entities/notification_health.dart';
import '../logic/oem_copy.dart';

class OemGuidanceCard extends StatelessWidget {
  final OemInfo oem;
  final VoidCallback onOpen;

  const OemGuidanceCard({super.key, required this.oem, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    if (!oem.needsAttention) return const SizedBox.shrink();
    return Card(
      color: Colors.orange.shade50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تحتاج إعداد إضافي على ${const OemCopy().label(oem.vendor)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(const OemCopy().guidanceMessage(oem.vendor)),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: ElevatedButton.icon(
                onPressed: oem.autostartAvailable ? onOpen : null,
                icon: const Icon(Icons.open_in_new),
                label: const Text('فتح الإعدادات'),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
