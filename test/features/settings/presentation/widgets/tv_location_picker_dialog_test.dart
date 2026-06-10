import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:ghasaq/core/city_translations.dart';
import 'package:ghasaq/core/error/failures.dart';
import 'package:ghasaq/core/platform_config.dart';
import 'package:ghasaq/features/settings/domain/entities/online_geocoding_result.dart';
import 'package:ghasaq/features/settings/domain/entities/world_city.dart';
import 'package:ghasaq/features/settings/domain/i_online_geocoding_repository.dart';
import 'package:ghasaq/features/settings/presentation/bloc/location_selection_cubit.dart';
import 'package:ghasaq/features/settings/presentation/bloc/online_geocoding_cubit.dart';
import 'package:ghasaq/features/settings/presentation/bloc/tv_location_picker_cubit.dart';
import 'package:ghasaq/features/settings/presentation/settings_provider.dart';
import 'package:ghasaq/features/settings/presentation/widgets/tv_location_picker/tv_location_picker_dialog.dart';
import 'package:ghasaq/features/prayer/data/composite_prayer_repository.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../support/settings_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadCityTranslations();
    // Production code calls `kIsTV` (which reads `PlatformConfig` from
    // GetIt) when building the country list. The test environment never
    // boots `initDependencies`, so register a benign mobile-mode instance.
    if (!GetIt.I.isRegistered<PlatformConfig>()) {
      GetIt.I.registerSingleton<PlatformConfig>(PlatformConfig());
    }
  });

  late CompositePrayerRepository fakeCompositeRepo;

  setUp(() async {
    fakeCompositeRepo = await buildFakeCompositeRepo();
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
                  builder: (_) =>
                      ChangeNotifierProvider<SettingsProvider>.value(
                        value: settingsProvider,
                        child: MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (_) => LocationSelectionCubit(
                                settingsProvider,
                                FakeDownloadCityUseCase(),
                                fakeCompositeRepo,
                              ),
                            ),
                            BlocProvider(
                              create: (_) => TvLocationPickerCubit(
                                worldRepo,
                                currentCountry:
                                    settingsProvider.settings.selectedCountry,
                                currentCity:
                                    settingsProvider.settings.selectedCity,
                              )..load(),
                            ),
                            BlocProvider(
                              create: (_) =>
                                  OnlineGeocodingCubit(_StubOnlineGeocoding()),
                            ),
                          ],
                          child: const TvLocationPickerDialog(),
                        ),
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

/// Always returns no results so the inline online section stays hidden
/// during widget tests focused on the bundled search path.
class _StubOnlineGeocoding implements IOnlineGeocodingRepository {
  @override
  Future<Either<Failure, List<OnlineGeocodingResult>>> search(
    String q, {
    String? countryCode,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, OnlineGeocodingResult?>> reverse({
    required double latitude,
    required double longitude,
    String? localeHint,
  }) async => const Right(null);
}
