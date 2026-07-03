import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../quran/domain/entities/quran_reciter.dart';
import '../widgets/reciter_moshaf_tile.dart';

/// Dropdown-style dialog listing the طرق (moshafs) of a single reciter. Shown
/// from the settings «القراءة» row so the user refines the recitation of the
/// already-chosen reciter. Selecting a طريقة returns its server URL.
class MoshafPickerDialog extends StatelessWidget {
  final QuranApiReciter reciter;
  final String currentServerUrl;
  final AccentPalette palette;
  final bool isRtl;
  final void Function(String serverUrl) onSelected;

  const MoshafPickerDialog({
    required this.reciter,
    required this.currentServerUrl,
    required this.palette,
    required this.isRtl,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 540,
          constraints: const BoxConstraints(maxHeight: 520),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.queue_music_rounded,
                    color: palette.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${l.reciterSelectMoshaf} — ${reciter.nameAr}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: reciter.moshafs.length,
                  itemBuilder: (_, i) {
                    final m = reciter.moshafs[i];
                    return ReciterMoshafTile(
                      moshaf: m,
                      isSelected: m.serverUrl == currentServerUrl,
                      isDefault: m.serverUrl == reciter.serverUrl,
                      accent: palette.primary,
                      onSelect: () {
                        onSelected(m.serverUrl);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
