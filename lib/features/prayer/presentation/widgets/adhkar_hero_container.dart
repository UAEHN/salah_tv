import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../adhkar/domain/entities/adhkar_session.dart';
import '../../../adhkar/domain/i_adhkar_audio_port.dart';
import '../../../adhkar/domain/i_adhkar_state_repository.dart';
import '../../../adhkar/presentation/bloc/adhkar_hero_cubit.dart';
import 'adhkar_hero_content.dart';

class AdhkarHeroContainer extends StatelessWidget {
  final AdhkarSession session;

  const AdhkarHeroContainer({required this.session, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdhkarHeroCubit>(
      key: ValueKey('adhkar_provider_${session.name}'),
      create: (context) => AdhkarHeroCubit(
        context.read<IAdhkarAudioPort>(),
        context.read<IAdhkarStateRepository>(),
      )..start(session),
      child: AdhkarHeroContent(session: session),
    );
  }
}
