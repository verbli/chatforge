import 'package:chatforge/data/storage/drivers/database_driver.dart';
import 'package:chatforge/data/storage/services/database_service.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Concrete implementation of `DatabaseService` using Sqflite.
class SqfliteService extends DatabaseService {
  final DatabaseDriver driver;
  static const String dbName = 'chatforge.db';
  static const int _currentVersion = 2;

  SqfliteService(this.driver);

  @override
  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    await driver.open(
      path: path,
      version: _currentVersion,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(
      dynamic db,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      // Add token_usage table if updating from version 1
      await driver.execute('''
        CREATE TABLE IF NOT EXISTS token_usage(
          model_key TEXT PRIMARY KEY,
          total_input_tokens INTEGER NOT NULL DEFAULT 0,
          total_output_tokens INTEGER NOT NULL DEFAULT 0,
          updated_at INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
  }

  Future<void> _createDb(dynamic db, int version) async {
    await driver.execute('''
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

    await driver.execute('''
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

    await driver.execute('''
    CREATE TABLE token_usage(
      model_key TEXT PRIMARY KEY,
      total_input_tokens INTEGER NOT NULL DEFAULT 0,
      total_output_tokens INTEGER NOT NULL DEFAULT 0,
      updated_at INTEGER NOT NULL DEFAULT 0
    )
  ''');

    // Add indexes
    await driver.execute(
        'CREATE INDEX idx_messages_conversation ON messages(conversation_id)');
  }

  @override
  Future<void> execute(String query, [List<dynamic>? arguments]) async {
    await driver.execute(query, arguments);
  }

  @override
  Future<List<Map<String, dynamic>>> query(
      String table, {
        bool? distinct,
        List<String>? columns,
        String? where,
        List<dynamic>? whereArgs,
        String? groupBy,
        String? having,
        String? orderBy,
        int? limit,
        int? offset,
      }) async {
    final sql = StringBuffer('SELECT');
    if (distinct == true) {
      sql.write(' DISTINCT');
    }
    if (columns != null) {
      sql.write(' ${columns.join(', ')}');
    } else {
      sql.write(' *');
    }
    sql.write(' FROM $table');
    if (where != null) {
      sql.write(' WHERE $where');
    }
    if (groupBy != null) {
      sql.write(' GROUP BY $groupBy');
    }
    if (having != null) {
      sql.write(' HAVING $having');
    }
    if (orderBy != null) {
      sql.write(' ORDER BY $orderBy');
    }
    if (limit != null) {
      sql.write(' LIMIT $limit');
    }
    if (offset != null) {
      sql.write(' OFFSET $offset');
    }

    return await driver.query(sql.toString(), whereArgs);
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final sql = StringBuffer('INSERT INTO $table');
    final columns = values.keys.toList();
    final placeholders = List.filled(columns.length, '?').join(', ');
    sql.write(' (${columns.join(', ')}) VALUES ($placeholders)');
    return await driver.insert(sql.toString(), values.values.toList());
  }

  @override
  Future<int> update(
      String table,
      Map<String, dynamic> values, {
        String? where,
        List<dynamic>? whereArgs,
      }) async {
    final sql = StringBuffer('UPDATE $table SET');
    final args = <dynamic>[];
    values.forEach((key, value) {
      sql.write(' $key = ?,');
      args.add(value);
    });
    sql.write(where != null ? ' WHERE $where' : '');
    if (whereArgs != null) {
      args.addAll(whereArgs);
    }
    return await driver.update(
      sql.toString().substring(0, sql.length - 1),
      args,
    );
  }

  @override
  Future<int> delete(
      String table, {
        String? where,
        List<dynamic>? whereArgs,
      }) async {
    final sql = StringBuffer('DELETE FROM $table');
    sql.write(where != null ? ' WHERE $where' : '');
    return await driver.delete(sql.toString(), whereArgs);
  }

  @override
  Future<T> transaction<T>(
      Future<T> Function(DatabaseService txn) action) async {
    return driver.transaction<T>((txn) async {
      final transactionDatabaseService = SqfliteTransactionService(txn);
      return await action(transactionDatabaseService);
    });
  }

  @override
  Future<int?> firstIntValue(String sql, [List<dynamic>? arguments]) async {
    return driver.firstIntValue(sql, arguments);
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]) async {
    return driver.rawQuery(sql, arguments);
  }

  @override
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    return driver.rawUpdate(sql, arguments);
  }

  @override
  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    return driver.rawDelete(sql, arguments);
  }

  @override
  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    return driver.rawInsert(sql, arguments);
  }
}

class SqfliteTransactionService extends DatabaseService {
  final dynamic txn;

  SqfliteTransactionService(this.txn);

  @override
  Future<void> initialize() async {
    // No action required
  }

  @override
  Future<void> execute(String query, [List<dynamic>? arguments]) async {
    await txn.execute(query, arguments);
  }

  @override
  Future<List<Map<String, dynamic>>> query(
      String table, {
        bool? distinct,
        List<String>? columns,
        String? where,
        List<dynamic>? whereArgs,
        String? groupBy,
        String? having,
        String? orderBy,
        int? limit,
        int? offset,
      }) async {
    return txn.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values) async {
    return txn.insert(table, values);
  }

  @override
  Future<int> update(
      String table,
      Map<String, dynamic> values, {
        String? where,
        List<dynamic>? whereArgs,
      }) async {
    return txn.update(table, values, where: where, whereArgs: whereArgs);
  }

  @override
  Future<int> delete(
      String table, {
        String? where,
        List<dynamic>? whereArgs,
      }) async {
    return txn.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<T> transaction<T>(
      Future<T> Function(DatabaseService txn) action) async {
    throw UnsupportedError("Transactions within transactions are not supported.");
  }

  @override
  Future<int?> firstIntValue(String sql, [List<dynamic>? arguments]) async {
    return Sqflite.firstIntValue(await txn.rawQuery(sql, arguments));
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]) async {
    return txn.rawQuery(sql, arguments);
  }

  @override
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    return txn.rawUpdate(sql, arguments);
  }

  @override
  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    return txn.rawDelete(sql, arguments);
  }

  @override
  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    return txn.rawInsert(sql, arguments);
  }
}