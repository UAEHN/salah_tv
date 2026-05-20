import 'package:flutter_test/flutter_test.dart';

import 'package:ghasaq/features/customization/presentation/logic/customization_l10n_resolver.dart';

void main() {
  group('themeKeyToLabelKey', () {
    test('maps every legacy key', () {
      expect(themeKeyToLabelKey('green'), 'themeGreen');
      expect(themeKeyToLabelKey('teal'), 'themeTeal');
      expect(themeKeyToLabelKey('gold'), 'themeGold');
      expect(themeKeyToLabelKey('blue'), 'themeBlue');
      expect(themeKeyToLabelKey('purple'), 'themePurple');
    });

    test('maps every mobile-only key', () {
      expect(themeKeyToLabelKey('desert_dawn'), 'themeCoral');
      expect(themeKeyToLabelKey('paradise_sea'), 'themeAzure');
    });

    test('falls back to themeGreen on unknown key', () {
      expect(themeKeyToLabelKey('unknown'), 'themeGreen');
      expect(themeKeyToLabelKey(''), 'themeGreen');
    });
  });

  group('fontFamilyToLabelKey', () {
    test('maps known families', () {
      expect(fontFamilyToLabelKey('Kufi'), 'fontKufi');
      expect(fontFamilyToLabelKey('Cairo'), 'fontCairo');
      expect(fontFamilyToLabelKey('Beiruti'), 'fontBeiruti');
      expect(fontFamilyToLabelKey('Rubik'), 'fontRubik');
      expect(fontFamilyToLabelKey('Inter'), 'fontInter');
    });

    test('falls back to fontKufi on unknown family', () {
      expect(fontFamilyToLabelKey('Comic Sans'), 'fontKufi');
      expect(fontFamilyToLabelKey(''), 'fontKufi');
    });
  });
}
