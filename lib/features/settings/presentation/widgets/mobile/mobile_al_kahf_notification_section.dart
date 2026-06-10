import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../notifications/data/native_notification_engine.dart';
import '../../settings_provider.dart';
import 'mobile_notification_reminder_row.dart';
import 'mobile_settings_section_title.dart';

/// Friday Surah Al-Kahf reminder section. Single inline row with toggle +
/// time chip. The optional helper subtitle sits inside the card as a small
/// caption, anchored to the same surface as the row it explains.
class MobileAlKahfNotificationSection extends StatelessWidget {
  const MobileAlKahfNotificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sp = context.watch<SettingsProvider>();
    final s = sp.settings;
    final cardColor = MobileColors.cardColor(context);

    return Column(
      children: [
        MobileSettingsSectionTitle(
          title: l.settingsAlKahfReminderTitle,
          icon: Icons.menu_book_rounded,
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: MobileColors.border(context).withValues(alpha: 0.7),
            ),
            boxShadow: MobileShadows.sleekCard(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.settingsAlKahfReminderSubtitle,
                style: MobileTextStyles.bodyMd(context).copyWith(
                  color: MobileColors.onSurfaceMuted(context),
                  fontSize: 12.5,
                  height: 1.45,
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
              ),
              MobileNotificationReminderRow(
                icon: Icons.brightness_5_rounded,
                label: l.settingsAlKahfReminderTitle,
                isOn: s.isAlKahfReminderEnabled,
                minuteOfDay: s.alKahfReminderMinuteOfDay,
                pickerTitle: l.settingsAlKahfReminderOffsetTitle,
                onChanged: sp.updateAlKahfReminder,
                onPickTime: sp.updateAlKahfReminderMinuteOfDay,
              ),
              if (kDebugMode) const _AlKahfDebugTestButton(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Fires the Al-Kahf notification 5 seconds from now. Debug-only — guarded
/// at the call site with `kDebugMode` so it's compiled out of release.
class _AlKahfDebugTestButton extends StatefulWidget {
  const _AlKahfDebugTestButton();

  @override
  State<_AlKahfDebugTestButton> createState() => _AlKahfDebugTestButtonState();
}

class _AlKahfDebugTestButtonState extends State<_AlKahfDebugTestButton> {
  bool _busy = false;

  Future<void> _fire() async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    await GetIt.I<NativeNotificationEngine>().runAlKahfTest();
    if (!mounted) return;
    setState(() => _busy = false);
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('سيصلك إشعار الكهف خلال 5 ثوانٍ ⏱'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 10),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: OutlinedButton.icon(
          onPressed: _busy ? null : _fire,
          icon: _busy
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.bug_report_outlined, size: 16, color: accent),
          label: Text(
            'اختبار الإشعار (debug)',
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: accent.withValues(alpha: 0.4)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
        ),
      ),
    );
  }
}
