import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import 'tv_feedback_contact_field.dart';
import 'tv_feedback_message_field.dart';
import 'tv_feedback_submit_button.dart';

class TvFeedbackFormColumn extends StatelessWidget {
  final TextEditingController messageController;
  final TextEditingController contactController;
  final bool isLoading;
  final ThemeColors tc;
  final Color accent;
  final VoidCallback onSubmit;

  const TvFeedbackFormColumn({
    required this.messageController,
    required this.contactController,
    required this.isLoading,
    required this.tc,
    required this.accent,
    required this.onSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.feedbackSubtitle,
          style: TextStyle(fontSize: 16, color: tc.textMuted),
        ),
        const SizedBox(height: 24),
        TvFeedbackMessageField(
          controller: messageController,
          hint: l.feedbackMessageHint,
          tc: tc,
          accent: accent,
        ),
        const SizedBox(height: 16),
        TvFeedbackContactField(
          controller: contactController,
          hint: l.feedbackContactLabel,
          tc: tc,
        ),
        const SizedBox(height: 24),
        TvFeedbackSubmitButton(
          label: l.feedbackSend,
          isLoading: isLoading,
          tc: tc,
          accent: accent,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}
