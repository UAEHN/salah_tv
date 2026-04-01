import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/mobile_theme.dart';
import '../bloc/tasbih_bloc.dart';
import '../bloc/tasbih_event.dart';

class TasbihTopBar extends StatelessWidget {
  const TasbihTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).pop(),
            color: MobileColors.onSurface(context),
          ),
          Expanded(
            child: Text(
              l.navTasbih,
              style: MobileTextStyles.titleMd(context),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l.tasbihResetTooltip,
            color: MobileColors.onSurface(context),
            onPressed: () => context.read<TasbihBloc>().add(const TasbihReset()),
          ),
        ],
      ),
    );
  }
}
