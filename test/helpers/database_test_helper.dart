import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

void setupSqfliteForTest() {
  sqfliteFfiInit();

  databaseFactory = databaseFactoryFfi;
}

Future<Database> createTestDatabase() async {
  return await openDatabase(
    inMemoryDatabasePath,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE tasks(
          local_id INTEGER PRIMARY KEY AUTOINCREMENT,
          server_id INTEGER,
          title TEXT NOT NULL,
          description TEXT,
          completed INTEGER DEFAULT 0,
          user_id TEXT NOT NULL,
          created_at TEXT,
          is_synced INTEGER DEFAULT 0
        )
      ''');
    },
  );
}
