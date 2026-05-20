import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../settings/presentation/settings_provider.dart';
import '../cubit/feedback_cubit.dart';
import '../cubit/feedback_state.dart';
import '../logic/feedback_settings_snapshot.dart';
import 'mobile_feedback_contact_field.dart';
import 'mobile_feedback_direct_contact.dart';
import 'mobile_feedback_header.dart';
import 'mobile_feedback_message_field.dart';
import 'mobile_feedback_submit_button.dart';

class MobileFeedbackForm extends StatefulWidget {
  const MobileFeedbackForm({super.key});

  @override
  State<MobileFeedbackForm> createState() => _MobileFeedbackFormState();
}

class _MobileFeedbackFormState extends State<MobileFeedbackForm> {
  final _messageController = TextEditingController();
  final _contactController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<FeedbackCubit>();
    final settings = context.watch<SettingsProvider>().settings;

    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocBuilder<FeedbackCubit, FeedbackState>(
      builder: (context, state) {
        return ListView(
          // Pad the bottom by the keyboard inset so a focused field at the
          // bottom of the form can scroll above the soft keyboard instead of
          // being clipped by it.
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: keyboardInset + 24,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            const SizedBox(height: 16),
            MobileFeedbackHeader(l: l),
            const SizedBox(height: 28),
            MobileFeedbackMessageField(
              controller: _messageController,
              hint: l.feedbackMessageHint,
            ),
            const SizedBox(height: 20),
            MobileFeedbackContactField(
              controller: _contactController,
              label: l.feedbackContactLabel,
              hint: l.feedbackContactHint,
              errorText: state.isContactMissing
                  ? l.feedbackContactRequiredError
                  : null,
            ),
            const SizedBox(height: 24),
            MobileFeedbackDirectContact(
              title: l.feedbackDirectContactTitle,
              emailLabel: l.feedbackContactEmail,
              telegramLabel: l.feedbackContactTelegram,
            ),
            const SizedBox(height: 24),
            MobileFeedbackSubmitButton(
              label: l.feedbackSend,
              isLoading: state.isLoading,
              onTap: () => cubit.submit(
                message: _messageController.text,
                contact: _contactController.text,
                settingsSnapshot: buildFeedbackSettingsSnapshot(settings),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
