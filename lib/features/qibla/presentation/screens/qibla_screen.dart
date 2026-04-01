import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/platform_config.dart';
import '../../domain/i_qibla_repository.dart';
import '../bloc/qibla_cubit.dart';
import 'mobile/mobile_qibla_screen.dart';

class QiblaScreen extends StatelessWidget {
  final String city;
  final String country;

  const QiblaScreen({
    super.key,
    required this.city,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsTV) {
      return BlocProvider(
        create: (_) => QiblaCubit(GetIt.I<IQiblaRepository>())..start(),
        child: MobileQiblaScreen(city: city, country: country),
      );
    }

    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Text(
          l.qiblaNotAvailableOnTv,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
