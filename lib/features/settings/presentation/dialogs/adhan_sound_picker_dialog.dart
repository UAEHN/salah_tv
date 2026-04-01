import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/adhan_sounds.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/localization/adhan_sound_localizer.dart';

class AdhanSoundPickerDialog extends StatelessWidget {
  final AccentPalette palette;
  final String selectedKey;
  final ValueChanged<String> onSelected;

  const AdhanSoundPickerDialog({
    required this.palette,
    required this.selectedKey,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.volume_up_rounded, color: palette.primary, size: 26),
                  const SizedBox(width: 12),
                  Text(
                    l.settingsChooseAdhanSound,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.white12),
              const SizedBox(height: 4),
              ListView.separated(
                shrinkWrap: true,
                itemCount: kAdhanSounds.length,
                separatorBuilder: (_, _) =>
                    const Divider(color: Colors.white10, height: 1),
                itemBuilder: (context, i) {
                  final key = kAdhanSounds[i].key;
                  final label = localizedAdhanSoundLabel(context, key);
                  final isSelected = key == selectedKey;
                  return ListTile(
                    leading: Icon(
                      Icons.music_note_rounded,
                      color: isSelected ? palette.primary : Colors.white38,
                    ),
                    title: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? palette.primary : Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.normal,
                        fontSize: 18,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: palette.primary)
                        : null,
                    onTap: () {
                      onSelected(key);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
