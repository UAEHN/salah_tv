import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

/// Minimal header — single settings icon (turquoise), RTL aligned right.
class MobileTopBar extends StatelessWidget {
  const MobileTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            color: MobileColors.primaryContainer,
            iconSize: 26,
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
    );
  }
}
