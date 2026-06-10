import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

/// City row pinned above the suggested-method banner. Tiny widget kept
/// in its own file purely to keep the picker screen under the 150-line
/// SRP budget.
class MethodPickerCityHeader extends StatelessWidget {
  final String name;
  const MethodPickerCityHeader({required this.name, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            color: MobileColors.onSurfaceMuted(context),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              color: MobileColors.onSurface(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small all-caps-ish section label used to separate the suggested card
/// from the alternatives list.
class MethodPickerSectionLabel extends StatelessWidget {
  final String text;
  const MethodPickerSectionLabel({required this.text, super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
    child: Text(
      text,
      style: TextStyle(
        color: MobileColors.onSurfaceMuted(context),
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),
  );
}
