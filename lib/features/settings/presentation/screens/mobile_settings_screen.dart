import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mobile_theme.dart';
import '../settings_provider.dart';
import '../widgets/mobile/mobile_settings_list.dart';

class MobileSettingsScreen extends StatelessWidget {
  const MobileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gradientColors = MobileColors.homeGradient(context);
    final mq = MediaQuery.of(context);
    final fontFamily = context.select<SettingsProvider, String>(
      (p) => p.settings.fontFamily,
    );
    final isRubik = fontFamily == 'Rubik';
    final scaledMq = isRubik
        ? mq
        : mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 1.15,
              maxScaleFactor: 1.3,
            ),
          );

    return MediaQuery(
      data: scaledMq,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),
          const SafeArea(bottom: false, child: MobileSettingsList()),
        ],
      ),
    );
  }
}
