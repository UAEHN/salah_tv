import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

class MobileLocationEmptyState extends StatelessWidget {
  final String message;

  const MobileLocationEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MobileColors.onSurfaceMuted(context)
                  .withValues(alpha: 0.08),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.search_off_rounded,
              size: 28,
              color: MobileColors.onSurfaceMuted(context),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: MobileTextStyles.bodyMd(context).copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
