import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class TopBar extends StatelessWidget {
  final AccentPalette palette;

  const TopBar({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: screenH * 0.012),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: palette.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
        ],
      ),
    );
  }
}
