import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../../core/widgets/mobile/mobile_bottom_nav.dart';
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pushReplacementNamed(context, '/');
      },
      child: Scaffold(
      extendBody: true,
      backgroundColor: MobileColors.background(context),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: MobileColors.qiblaGradient(context),
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MobileColors.primaryContainer.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: const SizedBox(),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                MobileQiblaTopBar(city: city, country: country),
                Expanded(child: _QiblaBody()),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MobileBottomNav(currentIndex: 1),
          ),
        ],
      ),
    ),
    );
  }
}

class _QiblaBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QiblaCubit, QiblaState>(
      builder: (context, state) => switch (state) {
        QiblaActive() => MobileQiblaActiveView(data: state.data),
        QiblaLoading() => const Center(child: CircularProgressIndicator()),
        QiblaPermissionDenied() => MobileQiblaStatusView(
            icon: Icons.location_off_rounded,
            title: 'الموقع مرفوض',
            subtitle: 'يرجى السماح بالوصول إلى الموقع من الإعدادات',
            onAction: () => context.read<QiblaCubit>().start(),
            actionLabel: 'إعادة المحاولة',
          ),
        QiblaLocationDisabled() => MobileQiblaStatusView(
            icon: Icons.gps_off_rounded,
            title: 'الـ GPS معطّل',
            subtitle: 'يرجى تفعيل خدمة الموقع',
            onAction: () => context.read<QiblaCubit>().start(),
            actionLabel: 'إعادة المحاولة',
          ),
        QiblaError() => MobileQiblaStatusView(
            icon: Icons.error_outline_rounded,
            title: 'خطأ',
            subtitle: state.message,
            onAction: () => context.read<QiblaCubit>().start(),
            actionLabel: 'إعادة المحاولة',
          ),
        QiblaInitial() => const SizedBox.shrink(),
      },
    );
  }
}
