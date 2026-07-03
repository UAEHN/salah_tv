import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings_decoders.dart';
import 'package:ghasaq/features/settings/domain/entities/custom_adhan.dart';

void main() {
  CustomAdhan custom(String fileName) => CustomAdhan(
    id: 'id-$fileName',
    label: 'My iqama',
    fileName: fileName,
    contentUri: '',
  );

  group('validatedIqamaSound', () {
    test('null falls back to default', () {
      expect(validatedIqamaSound(null, const []), 'default');
    });

    test('"default" is preserved', () {
      expect(validatedIqamaSound('default', const []), 'default');
    });

    test('keeps a custom key when its file exists in the list', () {
      final customs = [custom('abc.mp3')];
      expect(validatedIqamaSound('custom:abc.mp3', customs), 'custom:abc.mp3');
    });

    test('drops a custom key whose file is no longer in the list', () {
      final customs = [custom('abc.mp3')];
      expect(validatedIqamaSound('custom:gone.mp3', customs), 'default');
    });

    test('drops a custom key when the list is empty', () {
      expect(validatedIqamaSound('custom:abc.mp3', const []), 'default');
    });

    test('rejects an unknown built-in key (iqama has only "default")', () {
      // 'adhan2' is a valid ADHAN built-in but not an iqama one.
      expect(validatedIqamaSound('adhan2', const []), 'default');
    });
  });
}
