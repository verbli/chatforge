// data/storage/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models.dart';

class DatabaseService {
  static Database? _database;
  static const String dbName = 'chatforge.db';
  static const int _currentVersion = 2;  // Increment version number

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: _currentVersion,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onUpgrade(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      // Add token_usage table if updating from version 1
      await db.execute('''
        CREATE TABLE IF NOT EXISTS token_usage(
          model_key TEXT PRIMARY KEY,
          total_input_tokens INTEGER NOT NULL DEFAULT 0,
          total_output_tokens INTEGER NOT NULL DEFAULT 0,
          updated_at INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
  }

  static Future<void> _createDb(Database db, int version) async {
    await db.execute('''
    CREATE TABLE conversations(
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      provider_id TEXT NOT NULL,
      model_id TEXT NOT NULL,
      settings TEXT NOT NULL,
      total_input_tokens INTEGER NOT NULL DEFAULT 0,
      total_output_tokens INTEGER NOT NULL DEFAULT 0,
      sort_order INTEGER NOT NULL DEFAULT 0
    )
  ''');

    await db.execute('''
    CREATE TABLE messages(
      id TEXT PRIMARY KEY,
      conversation_id TEXT NOT NULL,
      content TEXT NOT NULL,
      role TEXT NOT NULL,
      timestamp INTEGER NOT NULL,
      token_count INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (conversation_id) REFERENCES conversations (id) 
        ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE token_usage(
      model_key TEXT PRIMARY KEY,
      total_input_tokens INTEGER NOT NULL DEFAULT 0,
      total_output_tokens INTEGER NOT NULL DEFAULT 0,
      updated_at INTEGER NOT NULL DEFAULT 0
    )
  ''');

    // Add indexes
    await db.execute(
        'CREATE INDEX idx_messages_conversation ON messages(conversation_id)');
  }

  static Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
