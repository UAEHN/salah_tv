import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: MobileColors.background.withValues(alpha: 0.85),
          padding: const EdgeInsets.fromLTRB(48, 12, 48, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Prayer — active
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [MobileColors.primary, MobileColors.primaryContainer],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_filled, color: Colors.white, size: 22),
                    const SizedBox(height: 2),
                    Text(
                      'الصلاة',
                      style: MobileTextStyles.labelSm.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              // Qibla — inactive placeholder
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.explore_outlined,
                    color: MobileColors.secondary.withValues(alpha: 0.6),
                    size: 22,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'القبلة',
                    style: MobileTextStyles.labelSm.copyWith(
                      color: MobileColors.secondary.withValues(alpha: 0.6),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
