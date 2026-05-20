import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../injection.dart';
import '../../../analytics/domain/i_analytics_service.dart';
import '../../../rating/domain/i_rating_service.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../domain/i_feedback_diagnostics_collector.dart';
import '../../domain/usecases/submit_feedback_usecase.dart';
import '../cubit/feedback_cubit.dart';
import '../cubit/feedback_state.dart';
import '../logic/feedback_settings_snapshot.dart';
import 'tv_feedback_form_column.dart';
import 'tv_feedback_qr_email_panel.dart';

class TvFeedbackSection extends StatelessWidget {
  const TvFeedbackSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => FeedbackCubit(
        ctx.read<SubmitFeedbackUseCase>(),
        getIt<IFeedbackDiagnosticsCollector>(),
        analytics: getIt<IAnalyticsService>(),
        rating: getIt<IRatingService>(),
      ),
      child: const _TvFeedbackContent(),
    );
  }
}

class _TvFeedbackContent extends StatefulWidget {
  const _TvFeedbackContent();

  @override
  State<_TvFeedbackContent> createState() => _TvFeedbackContentState();
}

class _TvFeedbackContentState extends State<_TvFeedbackContent> {
  final _messageController = TextEditingController();
  final _contactController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _showSnack(BuildContext context, String text, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onSubmit(BuildContext context, AppSettings settings) {
    final l = AppLocalizations.of(context);
    if (_messageController.text.trim().isEmpty) {
      _showSnack(context, l.feedbackEmptyError, Colors.red.shade700);
      return;
    }
    context.read<FeedbackCubit>().submit(
          message: _messageController.text,
          contact: _contactController.text,
          settingsSnapshot: buildFeedbackSettingsSnapshot(settings),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);

    return BlocListener<FeedbackCubit, FeedbackState>(
      listenWhen: (prev, curr) =>
          curr.isSuccess != prev.isSuccess ||
          curr.errorMessage != prev.errorMessage,
      listener: (context, state) {
        if (state.isSuccess) {
          _showSnack(context, l.feedbackSuccess, palette.primary);
          _messageController.clear();
          _contactController.clear();
        } else if (state.errorMessage != null) {
          _showSnack(context, l.feedbackError, Colors.red.shade700);
        }
      },
      child: BlocBuilder<FeedbackCubit, FeedbackState>(
        builder: (context, state) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TvFeedbackFormColumn(
                messageController: _messageController,
                contactController: _contactController,
                isLoading: state.isLoading,
                tc: tc,
                accent: palette.primary,
                onSubmit: () => _onSubmit(context, settings),
              ),
            ),
            const SizedBox(width: 48),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  TvFeedbackQrEmailPanel(
                    title: l.feedbackTvDirectTitle,
                    telegramCaption: l.feedbackTvQrTelegram,
                    emailCaption: l.feedbackTvQrEmail,
                    orFromPhoneLabel: l.feedbackTvOrFromPhone,
                    tc: tc,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
