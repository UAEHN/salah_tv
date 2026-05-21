import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../bloc/mushaf_reader_cubit.dart';

/// Toggle row for continuous-ayah playback. Extracted from the settings
/// sheet to keep that file under 150 lines.
class MobileMushafContinuousSection extends StatelessWidget {
  final bool enabled;
  const MobileMushafContinuousSection({super.key, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.mushafContinuousPlayback,
                style: MobileTextStyles.headlineMd(context),
              ),
              Text(
                l.mushafContinuousDescription,
                style: MobileTextStyles.labelSm(context),
              ),
            ],
          ),
        ),
        Switch(
          value: enabled,
          onChanged: (v) =>
              context.read<MushafReaderCubit>().setContinuousPlayback(v),
        ),
      ],
    );
  }
}
