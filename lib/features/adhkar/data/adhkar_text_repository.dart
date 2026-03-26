import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../domain/entities/adhkar_category.dart';
import '../domain/entities/text_dhikr.dart';
import '../domain/i_adhkar_text_repository.dart';

const _kIconMap = <String, String>{
  'wb_sunny': 'wb_sunny',
  'nights_stay': 'nights_stay',
  'mosque': 'mosque',
  'bedtime': 'bedtime',
  'alarm': 'alarm',
  'auto_stories': 'auto_stories',
};

/// Loads text-based adhkar from [assets/adhkar/adhkar_text.json].
/// Lazy-loaded: data is parsed on first access, not at construction time.
class AdhkarTextRepository implements IAdhkarTextRepository {
  List<AdhkarCategory>? _categories;
  Map<String, List<TextDhikr>>? _adhkarByCategory;

  Future<void> initialize() async {
    try {
      final raw = await rootBundle.loadString('assets/adhkar/adhkar_text.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _parseData(data);
    } catch (e) {
      debugPrint('[AdhkarTextRepo] initialize failed: $e');
      _categories = const [];
      _adhkarByCategory = const {};
    }
  }

  void _parseData(Map<String, dynamic> data) {
    final adhkarList = (data['adhkar'] as List)
        .cast<Map<String, dynamic>>()
        .map(TextDhikr.fromJson)
        .toList();

    _adhkarByCategory = {};
    for (final dhikr in adhkarList) {
      (_adhkarByCategory![dhikr.categoryId] ??= []).add(dhikr);
    }

    _categories = (data['categories'] as List)
        .cast<Map<String, dynamic>>()
        .map((c) {
          final id = c['id'] as String;
          return AdhkarCategory(
            id: id,
            nameAr: c['nameAr'] as String,
            icon: _kIconMap[c['icon'] as String] ?? 'auto_stories',
            totalCount: _adhkarByCategory![id]?.length ?? 0,
          );
        })
        .toList();
  }

  @override
  List<AdhkarCategory> getCategories() => _categories ?? const [];

  @override
  List<TextDhikr> getByCategory(String categoryId) {
    return _adhkarByCategory?[categoryId] ?? const [];
  }
}
