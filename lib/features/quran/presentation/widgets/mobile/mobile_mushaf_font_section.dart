import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/mushaf_preferences.dart';
import '../../bloc/mushaf_reader_cubit.dart';

/// Font-size slider for the Mushaf reader. Extracted from the settings
/// sheet to keep that file under 150 lines.
class MobileMushafFontSection extends StatelessWidget {
  final double size;
  const MobileMushafFontSection({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context).mushafFontSize,
              style: MobileTextStyles.headlineMd(context),
            ),
            const Spacer(),
            Text(
              size.round().toString(),
              style: MobileTextStyles.bodyMd(context),
            ),
          ],
        ),
        Slider(
          value: size,
          min: MushafPreferences.minFont,
          max: MushafPreferences.maxFont,
          divisions: 10,
          onChanged: (v) => context.read<MushafReaderCubit>().setFontSize(v),
        ),
      ],
    );
  }
}
