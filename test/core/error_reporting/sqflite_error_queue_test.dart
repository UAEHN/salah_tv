import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error_reporting/queue/error_queue_db_initializer.dart';
import 'package:ghasaq/core/error_reporting/queue/sqflite_error_queue.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    await ErrorQueueDbInitializer().createSchemaForTest(db);
  });

  tearDown(() => db.close());

  test('FIFO: peekOldest returns rows in enqueue order', () async {
    final queue = SqfliteErrorQueue(db);
    for (var i = 1; i <= 3; i++) {
      expect(await queue.enqueue({'n': i}), isTrue);
    }
    final batch = await queue.peekOldest(10);
    expect(batch.map((e) => e.payload?['n']).toList(), [1, 2, 3]);
  });

  test('cap enforcement drops the oldest rows', () async {
    final queue = SqfliteErrorQueue(db, maxRows: 3);
    for (var i = 1; i <= 5; i++) {
      await queue.enqueue({'n': i});
    }
    expect(await queue.count(), 3);
    final batch = await queue.peekOldest(10);
    expect(batch.map((e) => e.payload?['n']).toList(), [3, 4, 5]);
  });

  test('delete removes exactly the given batch', () async {
    final queue = SqfliteErrorQueue(db);
    for (var i = 1; i <= 3; i++) {
      await queue.enqueue({'n': i});
    }
    final batch = await queue.peekOldest(2);
    await queue.delete([for (final item in batch) item.id]);
    expect(await queue.count(), 1);
    final remaining = await queue.peekOldest(10);
    expect(remaining.single.payload?['n'], 3);
  });

  test('corrupt payload rows surface with a null payload', () async {
    final queue = SqfliteErrorQueue(db);
    await db.insert('error_queue', {
      'payload': 'this is not json',
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    await queue.enqueue({'n': 1});
    final batch = await queue.peekOldest(10);
    expect(batch.length, 2);
    expect(batch.first.payload, isNull);
    expect(batch.first.id, greaterThan(0));
    expect(batch.last.payload?['n'], 1);
  });
}
