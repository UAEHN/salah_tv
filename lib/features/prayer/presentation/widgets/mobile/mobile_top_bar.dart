import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

/// Minimal header — Location pill in the center, menu icon on the right.
class MobileTopBar extends StatelessWidget {
  final String city;
  final String country;

  const MobileTopBar({super.key, required this.city, required this.country});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Location Pill (Center) with Glassmorphism
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: MobileColors.cardColor(context).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: MobileColors.border(context)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: MobileColors.primaryContainer,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$city، $country',
                      style: MobileTextStyles.labelSm(
                        context,
                      ).copyWith(color: MobileColors.onSurfaceMuted(context)),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Menu/Settings Button (Right)
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.menu_rounded),
              color: MobileColors.primaryContainer,
              iconSize: 28,
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ),
        ],
      ),
    );
  }
}
