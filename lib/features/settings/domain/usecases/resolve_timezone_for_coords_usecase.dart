import '../i_timezone_resolver.dart';

class ResolveTimezoneForCoordsUseCase {
  final ITimezoneResolver _resolver;
  const ResolveTimezoneForCoordsUseCase(this._resolver);

  String? call(double latitude, double longitude) =>
      _resolver.resolve(latitude, longitude);
}
