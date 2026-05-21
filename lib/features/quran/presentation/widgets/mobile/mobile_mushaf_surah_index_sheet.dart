import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../../core/surahs_data.dart';
import '../../../domain/entities/surah.dart';
import 'mushaf_arabic_digits.dart';

/// Modal bottom sheet listing all 114 surahs. Tapping one returns its
/// number so the caller can jump to its first Mushaf page.
class MobileMushafSurahIndexSheet extends StatelessWidget {
  const MobileMushafSurahIndexSheet({super.key});

  static Future<int?> show(BuildContext context) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MobileMushafSurahIndexSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: MobileColors.cardColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _Handle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                AppLocalizations.of(context).mushafSurahIndex,
                style: MobileTextStyles.titleMd(context),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: kSurahs.length,
                itemBuilder: (_, i) => _SurahTile(surah: kSurahs[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: MobileColors.onSurfaceFaint(context),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  final Surah surah;
  const _SurahTile({required this.surah});

  @override
  Widget build(BuildContext context) {
    final primary = MobileColors.activePrimary(context);
    return ListTile(
      onTap: () => Navigator.of(context).pop(surah.number),
      leading: CircleAvatar(
        backgroundColor: primary.withValues(alpha: 0.15),
        child: Text(
          digitsForLocale(context, surah.number),
          style: TextStyle(color: primary, fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(
        surah.localizedName(Localizations.localeOf(context).languageCode),
        textAlign: TextAlign.right,
        style: MobileTextStyles.headlineMd(context),
      ),
      subtitle: Text(
        AppLocalizations.of(context)
            .mushafAyahsCount(digitsForLocale(context, surah.ayahCount)),
        textAlign: TextAlign.right,
        style: MobileTextStyles.labelSm(context),
      ),
    );
  }
}
