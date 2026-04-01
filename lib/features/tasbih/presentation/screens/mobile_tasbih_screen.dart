import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mobile_theme.dart';
import '../../domain/entities/tasbih_preset.dart';
import '../bloc/tasbih_bloc.dart';
import '../bloc/tasbih_event.dart';

import '../widgets/tasbih_page_content.dart';
import '../widgets/tasbih_top_bar.dart';

class MobileTasbihScreen extends StatefulWidget {
  const MobileTasbihScreen({super.key});

  @override
  State<MobileTasbihScreen> createState() => _MobileTasbihScreenState();
}

class _MobileTasbihScreenState extends State<MobileTasbihScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initial = context.read<TasbihBloc>().state.presetIndex;
    _pageController = PageController(initialPage: initial);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    HapticFeedback.selectionClick();
    context.read<TasbihBloc>().add(TasbihPresetChanged(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _Background(),
          SafeArea(
            child: Column(
              children: [
                const TasbihTopBar(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: kTasbihPresets.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (_, i) => TasbihPageContent(presetIndex: i),
                  ),
                ),
                const SizedBox(height: 88),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

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
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: const SizedBox(),
          ),
        ),
      ],
    );
  }
}
