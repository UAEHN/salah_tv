import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/platform_config.dart';
import '../../domain/entities/adhkar_session.dart';
import '../../domain/i_adhkar_text_repository.dart';
import '../bloc/adhkar_reader_cubit.dart';
import 'mobile/mobile_adhkar_screen.dart';

/// Platform-aware router: mobile shows the adhkar reader,
/// TV shows "not available" (adhkar text is mobile-only).
/// [initialSession] jumps directly into morning/evening when set — used by
/// the adhkar notification deep-link.
class AdhkarScreen extends StatelessWidget {
  final AdhkarSession? initialSession;

  const AdhkarScreen({super.key, this.initialSession});

  @override
  Widget build(BuildContext context) {
    if (!kIsTV) {
      return BlocProvider(
        create: (_) {
          final cubit = AdhkarReaderCubit(GetIt.I<IAdhkarTextRepository>());
          if (initialSession != null && initialSession != AdhkarSession.none) {
            cubit.openSession(initialSession!);
          } else {
            cubit.loadCategories();
          }
          return cubit;
        },
        child: const MobileAdhkarScreen(),
      );
    }

    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Text(
          l.adhkarNotAvailableOnTv,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
