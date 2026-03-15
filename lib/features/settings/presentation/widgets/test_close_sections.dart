import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tv_button.dart';

class CloseAppSection extends StatelessWidget {
  const CloseAppSection({super.key});

  @override
  Widget build(BuildContext context) {
    return TvButton(
      onPressed: () => SystemNavigator.pop(),
      accent: const Color(0xFFEF4444),
      filled: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text('إغلاق التطبيق', style: TextStyle(fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }
}
