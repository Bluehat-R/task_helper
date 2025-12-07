import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'task_helper.db');
    print('DB path: $path');

    return openDatabase(
      path,
      version: 5, // ← バージョンアップして再作成される
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        // ✅ ログ（PC起動記録など）
        await db.execute('''
          CREATE TABLE IF NOT EXISTS log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            timestamp TEXT NOT NULL
          )
        ''');

        // ✅ メンタル記録
        await db.execute('''
          CREATE TABLE IF NOT EXISTS mood (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            mood INTEGER,
            sleep_hours REAL,
            medicine TEXT, -- 💊 薬の記録
            note TEXT
          )
        ''');

        // ✅ 課題テーブル
        await db.execute('''
          CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            subject TEXT,
            due TEXT,
            status TEXT,
            done INTEGER DEFAULT 0,
            unique_id TEXT UNIQUE,
            updated_at TEXT
          )
        ''');

        // ✅ サブタスク
        await db.execute('''
          CREATE TABLE IF NOT EXISTS subtasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            parent_id INTEGER,
            title TEXT,
            done INTEGER DEFAULT 0,
            FOREIGN KEY(parent_id) REFERENCES tasks(id) ON DELETE CASCADE
          )
        ''');

        // ✅ 教科（Classroom連携用）
        await db.execute('''
          CREATE TABLE IF NOT EXISTS subjects (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE,
            active INTEGER DEFAULT 1
          )
        ''');

        // ✅ タスク行動ログ（タスクやサブタスクのチェック記録）
        await db.execute('''
          CREATE TABLE IF NOT EXISTS task_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task_title TEXT,
            subject TEXT,
            subtask_title TEXT,
            action TEXT, -- "完了" or "未完了"
            timestamp TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // 今後のアップデート対応用
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS task_log (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              task_title TEXT,
              subject TEXT,
              subtask_title TEXT,
              action TEXT,
              timestamp TEXT
            )
          ''');
        }
      },
    );
  }

  // ✅ 教科登録・有効化
  Future<void> insertOrActivateSubject(String name) async {
    final dbClient = await database;
    await dbClient.insert(
      'subjects',
      {'name': name, 'active': 1},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ✅ 有効な教科を取得
  Future<List<String>> getActiveSubjects() async {
    final dbClient = await database;
    final result = await dbClient.query(
      'subjects',
      where: 'active = ?',
      whereArgs: [1],
    );
    return result.map((e) => e['name'] as String).toList();
  }

  // ✅ 教科を無効化
  Future<void> deactivateSubject(String name) async {
    final dbClient = await database;
    await dbClient.update(
      'subjects',
      {'active': 0},
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  // ✅ Classroom連携で教科を自動登録
  Future<void> syncSubjects(List<String> classroomSubjects) async {
    final dbClient = await database;
    for (final subject in classroomSubjects) {
      await dbClient.insert(
        'subjects',
        {'name': subject, 'active': 1},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
