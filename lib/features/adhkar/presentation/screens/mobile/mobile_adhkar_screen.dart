import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/mobile_theme.dart';
import '../../bloc/adhkar_reader_cubit.dart';
import '../../bloc/adhkar_reader_state.dart';
import '../../widgets/mobile/mobile_adhkar_category_grid.dart';
import 'mobile_adhkar_reader_screen.dart';

class MobileAdhkarScreen extends StatelessWidget {
  const MobileAdhkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _Background(),
        SafeArea(
          bottom: false,
          child: BlocBuilder<AdhkarReaderCubit, AdhkarReaderState>(
            builder: (context, state) => switch (state) {
              AdhkarReaderCategories(:final categories) => Column(
                  children: [
                    _TopBar(title: 'الأذكار'),
                    Expanded(
                      child: MobileAdhkarCategoryGrid(
                        categories: categories,
                      ),
                    ),
                  ],
                ),
              AdhkarReaderReading() => const MobileAdhkarReaderScreen(),
              AdhkarReaderCompleted() => const MobileAdhkarReaderScreen(),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ),
      ],
    );
  }
}

class _Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: MobileColors.homeGradient(context),
              stops: const [0.0, 0.4, 0.7, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MobileColors.primary.withValues(alpha: 0.12),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MobileColors.secondary.withValues(
                alpha: MobileColors.isDark(context) ? 0.06 : 0.09,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: const SizedBox(),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: MobileTextStyles.titleMd(context),
        textAlign: TextAlign.center,
      ),
    );
  }
}
