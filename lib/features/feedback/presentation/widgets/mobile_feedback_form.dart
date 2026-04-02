import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../cubit/feedback_cubit.dart';
import '../cubit/feedback_state.dart';
import 'mobile_feedback_header.dart';
import 'mobile_feedback_message_field.dart';
import 'mobile_feedback_submit_button.dart';
import 'mobile_feedback_type_selector.dart';

class MobileFeedbackForm extends StatefulWidget {
  const MobileFeedbackForm({super.key});

  @override
  State<MobileFeedbackForm> createState() => _MobileFeedbackFormState();
}

class _MobileFeedbackFormState extends State<MobileFeedbackForm> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<FeedbackCubit>();

    return BlocBuilder<FeedbackCubit, FeedbackState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 16),
            MobileFeedbackHeader(l: l),
            const SizedBox(height: 28),
            MobileFeedbackTypeSelector(
              l: l,
              selectedType: state.selectedType,
              onSelect: cubit.selectType,
            ),
            const SizedBox(height: 20),
            MobileFeedbackMessageField(
              controller: _controller,
              hint: l.feedbackMessageHint,
            ),
            const SizedBox(height: 24),
            MobileFeedbackSubmitButton(
              label: l.feedbackSend,
              isLoading: state.isLoading,
              onTap: () => cubit.submit(_controller.text),
            ),
            const SizedBox(height: 40),
          ],
        );
      },
    );
  }
}
