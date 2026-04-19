import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/mobile_theme.dart';
import '../../domain/entities/tasbih_preset.dart';
import '../bloc/tasbih_bloc.dart';
import '../bloc/tasbih_event.dart';
import '../bloc/tasbih_state.dart';
import '../widgets/tasbih_completed_dialog.dart';
import '../widgets/tasbih_page_content.dart';
import '../widgets/tasbih_top_bar.dart';

class MobileTasbihScreen extends StatefulWidget {
  const MobileTasbihScreen({super.key});

  @override
  State<MobileTasbihScreen> createState() => _MobileTasbihScreenState();
}

class _MobileTasbihScreenState extends State<MobileTasbihScreen> {
  late final PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    HapticFeedback.selectionClick();
    context.read<TasbihBloc>().add(TasbihPresetChanged(index));
  }

  void _onCompleted(TasbihState state) {
    if (state.isAllCompleted) {
      _showAllCompletedDialog();
      return;
    }
    final next = state.presetIndex + 1;
    if (next >= kTasbihPresets.length) return;
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted || !_pageCtrl.hasClients) return;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _showAllCompletedDialog() {
    final l = AppLocalizations.of(context);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => TasbihCompletedDialog(
          title: l.tasbihAllCompletedTitle,
          body: l.tasbihAllCompletedBody,
        ),
      ).then((_) {
        if (mounted) Navigator.of(context).pop();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TasbihBloc, TasbihState>(
      listenWhen: (p, c) => !p.isCompleted && c.isCompleted,
      listener: (_, s) => _onCompleted(s),
      child: Scaffold(
        body: Stack(
          children: [
            _buildBackground(context),
            SafeArea(
              child: Column(
                children: [
                  const TasbihTopBar(),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageCtrl,
                      itemCount: kTasbihPresets.length,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (_, i) => TasbihPageContent(presetIndex: i),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: MobileColors.homeGradient(context),
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
    );
  }
}
