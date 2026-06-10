import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/entities/ayah_glyph_bounds.dart';
import '../domain/i_ayah_bounds_repository.dart';

/// Downloads `ayahinfo_1024.zip` from files.quran.app, extracts the
/// SQLite DB into the app docs dir, and exposes hit-test + per-ayah
/// glyph queries over it. Safe to call `ensureReady()` from any
/// `initState` — coalesces concurrent calls and is idempotent.
class AyahBoundsRepository implements IAyahBoundsRepository {
  static const String _zipUrl =
      'https://files.quran.app/hafs/madani/databases/ayahinfo/ayahinfo_1024.zip';
  static const String _dbFileName = 'ayahinfo_1024.db';

  final Dio _dio;
  Database? _db;
  Future<void>? _readyFuture;

  AyahBoundsRepository(this._dio);

  @override
  bool get isReady => _db != null;

  @override
  Future<void> ensureReady() {
    if (_db != null) return Future.value();
    return _readyFuture ??= _bootstrap();
  }

  Future<void> _bootstrap() async {
    final docs = await getApplicationDocumentsDirectory();
    final dbPath = '${docs.path}/$_dbFileName';
    final dbFile = File(dbPath);
    if (!await dbFile.exists()) {
      await _downloadAndExtract(dbPath);
    }
    _db = await openReadOnlyDatabase(dbPath);
  }

  Future<void> _downloadAndExtract(String dbPath) async {
    final response = await _dio.get<List<int>>(
      _zipUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = response.data;
    if (bytes == null) throw StateError('Empty ayahinfo zip response');
    final archive = ZipDecoder().decodeBytes(bytes);
    final entry = archive.files.firstWhere(
      (f) => f.isFile && f.name.endsWith('.db'),
      orElse: () => throw StateError('No .db inside ayahinfo zip'),
    );
    await File(dbPath).writeAsBytes(entry.content as List<int>);
  }

  @override
  Future<({int sura, int ayah})?> hitTest({
    required int pageNumber,
    required int imageX,
    required int imageY,
  }) async {
    final db = _db;
    if (db == null) return null;
    final rows = await db.rawQuery(
      '''
      SELECT sura_number, ayah_number FROM glyphs
       WHERE page_number = ?
         AND ? BETWEEN min_x AND max_x
         AND ? BETWEEN min_y AND max_y
       LIMIT 1
      ''',
      [pageNumber, imageX, imageY],
    );
    if (rows.isEmpty) return null;
    return (
      sura: rows.first['sura_number'] as int,
      ayah: rows.first['ayah_number'] as int,
    );
  }

  @override
  Future<List<AyahGlyphBounds>> glyphsForAyah({
    required int pageNumber,
    required int sura,
    required int ayah,
  }) async {
    final db = _db;
    if (db == null) return const [];
    final rows = await db.rawQuery(
      '''
      SELECT line_number, min_x, max_x, min_y, max_y FROM glyphs
       WHERE page_number = ? AND sura_number = ? AND ayah_number = ?
      ''',
      [pageNumber, sura, ayah],
    );
    return rows
        .map(
          (r) => AyahGlyphBounds(
            sura: sura,
            ayah: ayah,
            line: r['line_number'] as int,
            minX: r['min_x'] as int,
            maxX: r['max_x'] as int,
            minY: r['min_y'] as int,
            maxY: r['max_y'] as int,
          ),
        )
        .toList(growable: false);
  }
}
