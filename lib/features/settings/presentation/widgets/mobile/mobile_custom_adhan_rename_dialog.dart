import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';

class MobileCustomAdhanRenameDialog extends StatefulWidget {
  final String initialLabel;
  final ValueChanged<String> onSave;

  const MobileCustomAdhanRenameDialog({
    super.key,
    required this.initialLabel,
    required this.onSave,
  });

  @override
  State<MobileCustomAdhanRenameDialog> createState() =>
      _MobileCustomAdhanRenameDialogState();
}

class _MobileCustomAdhanRenameDialogState
    extends State<MobileCustomAdhanRenameDialog> {
  late final TextEditingController _ctrl = TextEditingController(
    text: widget.initialLabel,
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: MobileColors.cardColor(context),
      title: Text(
        l.settingsRenameAdhan,
        style: MobileTextStyles.titleMd(context),
        textDirection: TextDirection.rtl,
      ),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(hintText: l.settingsAdhanNameHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.commonCancel),
        ),
        TextButton(
          onPressed: () {
            final text = _ctrl.text.trim();
            if (text.isEmpty) return;
            widget.onSave(text);
            Navigator.pop(context);
          },
          child: Text(l.commonSave),
        ),
      ],
    );
  }
}
