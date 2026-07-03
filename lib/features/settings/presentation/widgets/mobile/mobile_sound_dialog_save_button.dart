import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

/// Shared gradient "save" button for the mobile sound picker bottom sheets
/// (adhan + iqama). Extracted so both dialogs stay DRY and identical.
class MobileSoundDialogSaveButton extends StatelessWidget {
  final VoidCallback onSave;
  final String label;

  const MobileSoundDialogSaveButton({
    super.key,
    required this.onSave,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onSave,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ).copyWith(elevation: WidgetStateProperty.all(0)),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [MobileColors.primary, MobileColors.primaryContainer],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              label,
              style: MobileTextStyles.titleMd(
                context,
              ).copyWith(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
