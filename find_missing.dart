import 'dart:io';

void main() {
  final file = File('lib/core/city_translations.dart');
  final content = file.readAsStringSync();

  final regex = RegExp(r"key:\s*'([^']+)'(?:.|\n)*?cities:\s*\[((?:[^\]]+))\]");
  final mapRegex = RegExp(r"'([^']+)':\s*'([^']+)',");

  final mappedCities = <String>{};
  for (final match in mapRegex.allMatches(content)) {
    mappedCities.add(match.group(1)!);
  }

  for (final match in regex.allMatches(content)) {
    final country = match.group(1);
    final citiesRaw = match.group(2);
    final cityMatches = RegExp(r"'([^']+)'").allMatches(citiesRaw!);
    for (final cm in cityMatches) {
      final city = cm.group(1)!;
      if (!mappedCities.contains(city)) {
        print("$country: $city");
      }
    }
  }
}
