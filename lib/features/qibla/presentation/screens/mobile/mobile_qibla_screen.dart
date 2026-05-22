import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../bloc/qibla_cubit.dart';
import '../../bloc/qibla_state.dart';
import '../../widgets/mobile/mobile_qibla_active_view.dart';
import '../../widgets/mobile/mobile_qibla_status_view.dart';
import '../../widgets/mobile/mobile_qibla_top_bar.dart';

class MobileQiblaScreen extends StatelessWidget {
  final String city;
  final String country;

  const MobileQiblaScreen({
    super.key,
    required this.city,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = MobileColors.isDark(context);
    final accent = MobileColors.activePrimary(context);
    final gradientColors = isDark
        ? const [Color(0xFF0F1729), Color(0xFF080C1A), Color(0xFF04060D)]
        : MobileColors.qiblaGradient(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -size.height * 0.08,
          left: -size.width * 0.25,
          child: IgnorePointer(
            child: Container(
              width: size.width * 1.1,
              height: size.width * 1.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: isDark ? 0.20 : 0.14),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              MobileQiblaTopBar(city: city, country: country),
              const Expanded(child: _QiblaBody()),
            ],
          ),
        ),
      ],
    );
  }
}

class _QiblaBody extends StatelessWidget {
  const _QiblaBody();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return BlocBuilder<QiblaCubit, QiblaState>(
      builder: (context, state) => switch (state) {
        QiblaActive() => MobileQiblaActiveView(data: state.data),
        QiblaLoading() => const Center(child: CircularProgressIndicator()),
        QiblaPermissionDenied() => MobileQiblaStatusView(
            icon: Icons.location_off_rounded,
            title: l.qiblaPermissionDeniedTitle,
            subtitle: l.qiblaPermissionDeniedSubtitle,
            onAction: () => context.read<QiblaCubit>().start(),
            actionLabel: l.commonRetry,
          ),
        QiblaLocationDisabled() => MobileQiblaStatusView(
            icon: Icons.gps_off_rounded,
            title: l.qiblaGpsDisabledTitle,
            subtitle: l.qiblaGpsDisabledSubtitle,
            onAction: () => context.read<QiblaCubit>().start(),
            actionLabel: l.commonRetry,
          ),
        QiblaError() => MobileQiblaStatusView(
            icon: Icons.error_outline_rounded,
            title: l.commonError,
            subtitle: state.message,
            onAction: () => context.read<QiblaCubit>().start(),
            actionLabel: l.commonRetry,
          ),
        QiblaInitial() => const SizedBox.shrink(),
      },
    );
  }
}
