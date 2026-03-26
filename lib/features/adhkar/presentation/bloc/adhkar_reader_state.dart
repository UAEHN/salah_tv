import '../../domain/entities/adhkar_category.dart';
import '../../domain/entities/text_dhikr.dart';

sealed class AdhkarReaderState {
  const AdhkarReaderState();
}

class AdhkarReaderInitial extends AdhkarReaderState {
  const AdhkarReaderInitial();
}

class AdhkarReaderCategories extends AdhkarReaderState {
  final List<AdhkarCategory> categories;

  const AdhkarReaderCategories(this.categories);
}

class AdhkarReaderReading extends AdhkarReaderState {
  final AdhkarCategory category;
  final List<TextDhikr> adhkar;
  final int currentIndex;
  final Map<int, int> remainingCounts;

  const AdhkarReaderReading({
    required this.category,
    required this.adhkar,
    required this.currentIndex,
    required this.remainingCounts,
  });

  bool get isFirst => currentIndex == 0;
  bool get isLast => currentIndex == adhkar.length - 1;
  TextDhikr get currentDhikr => adhkar[currentIndex];
  int get currentRemaining => remainingCounts[currentIndex] ?? 0;
  bool get isCurrentCompleted => currentRemaining <= 0;

  AdhkarReaderReading copyWith({
    int? currentIndex,
    Map<int, int>? remainingCounts,
  }) {
    return AdhkarReaderReading(
      category: category,
      adhkar: adhkar,
      currentIndex: currentIndex ?? this.currentIndex,
      remainingCounts: Map.unmodifiable(
        remainingCounts ?? this.remainingCounts,
      ),
    );
  }
}

class AdhkarReaderCompleted extends AdhkarReaderState {
  final AdhkarCategory category;

  const AdhkarReaderCompleted(this.category);
}
