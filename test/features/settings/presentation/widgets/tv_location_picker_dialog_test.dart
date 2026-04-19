import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/city_translations.dart';
import 'package:ghasaq/features/settings/domain/entities/world_city.dart';
import 'package:ghasaq/features/settings/presentation/bloc/location_selection_cubit.dart';
import 'package:ghasaq/features/settings/presentation/bloc/tv_location_picker_cubit.dart';
import 'package:ghasaq/features/settings/presentation/settings_provider.dart';
import 'package:ghasaq/features/settings/presentation/widgets/tv_location_picker/tv_location_picker_dialog.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../support/settings_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadCityTranslations();
  });

  Future<void> pumpDialog(
    WidgetTester tester, {
    required SettingsProvider settingsProvider,
    required FakeWorldCityRepository worldRepo,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) => LocationSelectionCubit(settingsProvider),
                      ),
                      BlocProvider(
                        create: (_) => TvLocationPickerCubit(
                          worldRepo,
                          currentCountry:
                              settingsProvider.settings.selectedCountry,
                          currentCity: settingsProvider.settings.selectedCity,
                        )..load(),
                      ),
                    ],
                    child: const TvLocationPickerDialog(),
                  ),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  FakeWorldCityRepository buildWorldRepo() {
    return FakeWorldCityRepository([
      const WorldCity(
        name: 'New York',
        arabicName: 'نيويورك',
        countryKey: 'US',
        countryArabic: 'الولايات المتحدة',
        latitude: 40.7128,
        longitude: -74.0060,
        calculationMethod: 'north_america',
        utcOffset: -5,
      ),
    ]);
  }

  testWidgets('navigates from countries to cities and back', (tester) async {
    final repo = FakeSettingsRepository();
    final provider = SettingsProvider(repo, repo.savedSettings);

    await pumpDialog(
      tester,
      settingsProvider: provider,
      worldRepo: buildWorldRepo(),
    );

    await tester.enterText(find.byType(TextField), 'United');
    await tester.pumpAndSettle();
    await tester.tap(find.text('United States'));
    await tester.pumpAndSettle();
    expect(find.text('New York'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Select country'), findsOneWidget);
    expect(find.text('New York'), findsNothing);
  });

  testWidgets('saves a world city and closes the dialog', (tester) async {
    final repo = FakeSettingsRepository();
    final provider = SettingsProvider(repo, repo.savedSettings);

    await pumpDialog(
      tester,
      settingsProvider: provider,
      worldRepo: buildWorldRepo(),
    );

    await tester.enterText(find.byType(TextField), 'United');
    await tester.pumpAndSettle();
    await tester.tap(find.text('United States'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New York'));
    await tester.pumpAndSettle();

    expect(provider.settings.selectedCountry, 'US');
    expect(provider.settings.selectedCity, 'New York');
    expect(provider.settings.isCalculatedLocation, isTrue);
    expect(find.byType(Dialog), findsNothing);
  });
}
