import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

class MobileHeroHijriRow extends StatelessWidget {
  final String hijriDate;

  const MobileHeroHijriRow({super.key, required this.hijriDate});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _arrowButton(context, Icons.chevron_left_rounded),
        const SizedBox(width: 20),
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: MobileColors.onSurfaceMuted(context),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              hijriDate,
              style: MobileTextStyles.bodyMd(
                context,
              ).copyWith(color: MobileColors.onSurface(context)),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
        const SizedBox(width: 20),
        _arrowButton(context, Icons.chevron_right_rounded),
      ],
    );
  }

  Widget _arrowButton(BuildContext context, IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: MobileColors.cardColor(context),
        ),
        child: Icon(icon, color: MobileColors.primaryContainer, size: 20),
      ),
    );
  }
}
