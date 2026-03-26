import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../../features/prayer/data/calculation_method_map.dart';
import 'mobile_select_option_tile.dart';

class MobileCalculationMethodDialog extends StatelessWidget {
  final String currentMethod;
  final ValueChanged<String> onSave;

  const MobileCalculationMethodDialog({
    super.key,
    required this.currentMethod,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = MobileColors.cardColor(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: MobileColors.border(context))),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(context),
            const SizedBox(height: 20),
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildNote(context),
            const SizedBox(height: 16),
            _buildList(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) => Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: MobileColors.onSurfaceMuted(context).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildHeader(BuildContext context) => Text(
        'طريقة الحساب',
        style: MobileTextStyles.titleMd(context).copyWith(
          color: MobileColors.onSurface(context),
          fontSize: 18,
        ),
      );

  Widget _buildNote(BuildContext context) => Text(
        'تؤثر على الأوقات المحسوبة (GPS) فقط',
        style: MobileTextStyles.bodyMd(context).copyWith(
          color: MobileColors.onSurfaceMuted(context),
          fontSize: 12,
        ),
        textDirection: TextDirection.rtl,
      );

  Widget _buildList(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.55,
        ),
        child: ListView(
          shrinkWrap: true,
          children: kCalculationMethodLabels.entries.map((e) {
            return MobileSelectOptionTile(
              title: e.value,
              icon: Icons.calculate_rounded,
              isSelected: currentMethod == e.key,
              onTap: () {
                onSave(e.key);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      );
}
