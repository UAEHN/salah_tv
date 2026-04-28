import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../injection.dart';
import '../../../analytics/domain/i_analytics_service.dart';
import '../../../rating/domain/i_rating_service.dart';
import '../../domain/usecases/submit_feedback_usecase.dart';
import '../cubit/feedback_cubit.dart';
import '../cubit/feedback_state.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../../../core/app_config.dart';
import '../../../rating/presentation/widgets/tv_rating_qr_panel.dart';

class TvFeedbackSection extends StatelessWidget {
  const TvFeedbackSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => FeedbackCubit(
        ctx.read<SubmitFeedbackUseCase>(),
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
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);
    final cubit = context.read<FeedbackCubit>();

    return BlocListener<FeedbackCubit, FeedbackState>(
      listenWhen: (prev, curr) =>
          curr.isSuccess != prev.isSuccess ||
          curr.errorMessage != prev.errorMessage,
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.feedbackSuccess),
              backgroundColor: palette.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _controller.clear();
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.feedbackError),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<FeedbackCubit, FeedbackState>(
        builder: (context, state) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.feedbackSubtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: tc.textMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _TvFeedbackMessageField(
                      controller: _controller,
                      hint: l.feedbackMessageHint,
                      tc: tc,
                      accent: palette.primary,
                    ),
                    const SizedBox(height: 24),
                    _TvFeedbackSubmitButton(
                      label: l.feedbackSend,
                      isLoading: state.isLoading,
                      tc: tc,
                      accent: palette.primary,
                      onPressed: () {
                        if (_controller.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.feedbackEmptyError),
                              backgroundColor: Colors.red.shade700,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        cubit.submit(_controller.text);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    TvRatingQrPanel(
                      url: AppConfig.tvFeedbackUrl,
                      icon: Icons.qr_code_scanner_rounded,
                      label: "مسح الرمز للكتابة من هاتفك", // Hardcoded for now, can be translated later if needed
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TvFeedbackMessageField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ThemeColors tc;
  final Color accent;

  const _TvFeedbackMessageField({
    required this.controller,
    required this.hint,
    required this.tc,
    required this.accent,
  });

  @override
  State<_TvFeedbackMessageField> createState() =>
      _TvFeedbackMessageFieldState();
}

class _TvFeedbackMessageFieldState extends State<_TvFeedbackMessageField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      decoration: widget.tc
          .glass(opacity: 0.07, borderRadius: 14)
          .copyWith(
            border: Border.all(
              color: _isFocused ? Colors.white : Colors.white12,
              width: _isFocused ? 2 : 1,
            ),
          ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        maxLines: 6,
        minLines: 6,
        textDirection: TextDirection.rtl,
        style: TextStyle(color: widget.tc.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: widget.tc.textMuted, fontSize: 16),
          contentPadding: const EdgeInsets.all(18),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _TvFeedbackSubmitButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final ThemeColors tc;
  final Color accent;
  final VoidCallback onPressed;

  const _TvFeedbackSubmitButton({
    required this.label,
    required this.isLoading,
    required this.tc,
    required this.accent,
    required this.onPressed,
  });

  @override
  State<_TvFeedbackSubmitButton> createState() =>
      _TvFeedbackSubmitButtonState();
}

class _TvFeedbackSubmitButtonState extends State<_TvFeedbackSubmitButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isActive = _isFocused;
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          if (!widget.isLoading) widget.onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: widget.tc
              .glass(opacity: 0.07, borderRadius: 14)
              .copyWith(
                color: isActive ? widget.accent : null,
                border: Border.all(
                  color: isActive ? Colors.white : Colors.white12,
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: widget.accent.withValues(alpha: 0.4),
                          blurRadius: 16,
                        )
                      ]
                    : null,
              ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : widget.tc.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
