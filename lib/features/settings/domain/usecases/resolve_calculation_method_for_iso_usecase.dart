import '../../../../core/calculation_method_info.dart';

/// Thin domain wrapper around [defaultMethodForCountryIso] so the
/// presentation layer doesn't reach into `core/` directly. The mapping
/// table stays in core where it's shared with detection / DB flows.
class ResolveCalculationMethodForIsoUseCase {
  const ResolveCalculationMethodForIsoUseCase();

  String call(String? isoCountryCode) =>
      defaultMethodForCountryIso(isoCountryCode);
}
