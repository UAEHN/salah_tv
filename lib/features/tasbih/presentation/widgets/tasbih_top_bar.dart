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
    final color = MobileColors.activePrimary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            color: color,
          ),
          const Spacer(),
          Text(l.navTasbih, style: MobileTextStyles.headlineMd(context)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: l.tasbihResetTooltip,
            color: color,
            onPressed: () =>
                context.read<TasbihBloc>().add(const TasbihReset()),
          ),
        ],
      ),
    );
  }
}
