import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/mobile_theme.dart';
import '../cubit/feedback_cubit.dart';
import '../cubit/feedback_state.dart';
import '../widgets/mobile_feedback_form.dart';

class MobileFeedbackScreen extends StatelessWidget {
  const MobileFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gradientColors = MobileColors.homeGradient(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
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
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MobileColors.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MobileColors.secondary.withValues(
                  alpha: MobileColors.isDark(context) ? 0.07 : 0.09,
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
          SafeArea(
            child: BlocListener<FeedbackCubit, FeedbackState>(
              listenWhen: (prev, curr) =>
                  curr.isSuccess != prev.isSuccess ||
                  curr.errorMessage != prev.errorMessage,
              listener: _onStateChange,
              child: const MobileFeedbackForm(),
            ),
          ),
        ],
      ),
    );
  }

  void _onStateChange(BuildContext context, FeedbackState state) {
    final l = AppLocalizations.of(context);
    if (state.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.feedbackSuccess),
          backgroundColor: MobileColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.feedbackError),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
