import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/app_colors.dart';
import '../../../domain/entities/adhkar_session.dart';
import '../../../domain/i_adhkar_audio_port.dart';
import '../../../domain/i_session_adhkar_repository.dart';
import '../../bloc/session_adhkar_cubit.dart';
import '../../widgets/tv/adhkar_takeover_body.dart';

/// Full-screen morning/evening session-adhkar takeover. Like the after-prayer
/// takeover visually, but audio-driven: it plays each dhikr's audio and advances
/// on completion. When the whole list finishes one pass it fires [onCompleted]
/// so the prayer engine resumes Quran. Self-provides its cubit + data so callers
/// only render `SessionAdhkarScreen(palette:, categoryId:, onCompleted:)`.
class SessionAdhkarScreen extends StatelessWidget {
  final AccentPalette palette;

  /// 'morning' | 'evening' — chosen by the engine from the just-finished prayer.
  final String categoryId;

  /// Fired once when the audio playlist completes one full pass.
  final VoidCallback onCompleted;

  const SessionAdhkarScreen({
    super.key,
    required this.palette,
    required this.categoryId,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEvening = categoryId == 'evening';
    final session = isEvening ? AdhkarSession.evening : AdhkarSession.morning;
    final title = isEvening ? l.adhkarEveningSession : l.adhkarMorningSession;
    final adhkar = GetIt.I<ISessionAdhkarRepository>().forSession(session);

    // No audio catalog (asset load failed) — nothing to play, so hand straight
    // back to the engine and let Quran resume instead of holding a blank screen.
    if (adhkar.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onCompleted());
      return const SizedBox.shrink();
    }

    return BlocProvider(
      create: (_) =>
          SessionAdhkarCubit(GetIt.I<IAdhkarAudioPort>())..start(adhkar),
      child: BlocListener<SessionAdhkarCubit, SessionAdhkarState>(
        listenWhen: (prev, curr) => !prev.isCompleted && curr.isCompleted,
        listener: (_, _) => onCompleted(),
        child: BlocBuilder<SessionAdhkarCubit, SessionAdhkarState>(
          builder: (context, state) {
            final dhikr = state.current;
            return AdhkarTakeoverBody(
              palette: palette,
              title: title,
              text: dhikr?.text ?? '',
              switchKey: state.index,
            );
          },
        ),
      ),
    );
  }
}
