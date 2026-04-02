import 'dart:async';

class OnboardingFilterController {
  Timer? _debounce;

  void runDebounced(void Function() action) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), action);
  }

  void dispose() {
    _debounce?.cancel();
  }
}
