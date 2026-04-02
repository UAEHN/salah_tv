import 'package:flutter/material.dart';

import '../../../../core/brand_colors.dart';
import 'onboarding_style.dart';

class OnboardingSelectableTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const OnboardingSelectableTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: onboardingSelectableTextStyle(isSelected)),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: brandGold, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
