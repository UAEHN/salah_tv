import 'package:flutter/material.dart';

import '../../../../core/brand_colors.dart';

TextStyle onboardingSelectableTextStyle(bool isSelected) {
  return TextStyle(
    color: isSelected ? brandGold : Colors.white.withValues(alpha: 0.88),
    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
  );
}
