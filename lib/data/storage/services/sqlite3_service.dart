// lib/data/storage/services/sqlite3_service.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import '../drivers/database_driver.dart';
import 'database_service.dart';

class SQLite3Service extends DatabaseService {
  final DatabaseDriver driver;
  static const String dbName = 'chatforge.db';
  static const int _currentVersion = 4;
  bool _inTransaction = false;

  SQLite3Service(this.driver);

  @override
  Future<void> initialize() async {
    String dbPath;
    if (kIsWeb) {
      dbPath = ':memory:';
    } else {
      final dir = await path_provider.getApplicationSupportDirectory();
      if (Platform.isWindows || Platform.isLinux) {
        // Create data directory if it doesn't exist
        final dataDir = Directory(join(dir.path, 'data'));
        if (!await dataDir.exists()) {
          await dataDir.create(recursive: true);
        }
        dbPath = join(dataDir.path, dbName);
      } else {
        dbPath = join(dir.path, dbName);
      }
    }

    await driver.open(
      path: dbPath,
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
      await driver.execute('''
        CREATE TABLE IF NOT EXISTS token_usage(
          model_key TEXT PRIMARY KEY,
          total_input_tokens INTEGER NOT NULL DEFAULT 0,
          total_output_tokens INTEGER NOT NULL DEFAULT 0,
          updated_at INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }

    if (oldVersion < 4) {
      // Add is_placeholder column to messages table
      await driver.execute('''
        ALTER TABLE messages 
        ADD COLUMN is_placeholder INTEGER NOT NULL DEFAULT 0
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
        total_tokens INTEGER NOT NULL DEFAULT 0,
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
        is_placeholder INTEGER NOT NULL DEFAULT 0,
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
    sql.write(columns?.join(', ') ?? ' *');
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
    var first = true;
    values.forEach((key, value) {
      if (!first) {
        sql.write(',');
      }
      first = false;
      sql.write(' $key = ?');
      args.add(value);
    });
    if (where != null) {
      sql.write(' WHERE $where');
    }
    if (whereArgs != null) {
      args.addAll(whereArgs);
    }
    return await driver.update(sql.toString(), args);
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
  Future<T> transaction<T>(Future<T> Function(DatabaseService txn) action) async {
    // Add guard against nested transactions
    if (_inTransaction) {
      throw StateError('Nested transactions are not supported');
    }
    _inTransaction = true;

    try {
      return await driver.transaction((txn) async {
        final transactionService = SQLite3TransactionService(txn);
        return await action(transactionService);
      });
    } finally {
      _inTransaction = false;
    }
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

class SQLite3TransactionService extends DatabaseService {
  final dynamic txn;

  SQLite3TransactionService(this.txn);

  @override
  Future<void> initialize() async {}

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
    final sql = StringBuffer('SELECT ');
    if (distinct == true) {
      sql.write(' DISTINCT');
    }
    sql.write(columns?.join(', ') ?? ' *');
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

    final results = await txn.select(sql.toString(), whereArgs ?? []);
    return results.map<Map<String, dynamic>>(
      (row) => Map<String, dynamic>.from(row as Map<String, dynamic>),
    ).toList();
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final sql = StringBuffer('INSERT INTO $table');
    final columns = values.keys.toList();
    final placeholders = List.filled(columns.length, '?').join(', ');
    sql.write(' (${columns.join(', ')}) VALUES ($placeholders)');
    txn.execute(sql.toString(), values.values.toList());
    return txn.lastInsertRowId;
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final sql = StringBuffer('UPDATE $table SET ');
      final args = <dynamic>[];
      var first = true;

      // Build SET clause
      values.forEach((key, value) {
        if (!first) sql.write(', ');
        sql.write('$key = \$${args.length + 1}');
        args.add(value);
        first = false;
      });

      // Add WHERE clause with proper parameter numbering
      if (where != null) {
        sql.write(' WHERE ');
        var whereClause = where;
        if (whereArgs != null) {
          whereArgs.asMap().forEach((i, _) {
            whereClause =
                whereClause.replaceFirst('?', '\$${args.length + i + 1}');
          });
          args.addAll(whereArgs);
        }
        sql.write(whereClause);
      }

      this
          .txn
          .execute(sql.toString(), args); // Use this.txn instead of just txn
      return this.txn.getUpdatedRows();
    } catch (e) {
      print('Error executing update: ${e.toString()}');
      print('Table: $table');
      print('Values: $values');
      print('Where: $where');
      print('WhereArgs: $whereArgs');
      rethrow;
    }
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final sql = StringBuffer('DELETE FROM $table');
    sql.write(where != null ? ' WHERE $where' : '');
    txn.execute(sql.toString(), whereArgs);
    return txn.getUpdatedRows();
  }

  @override
  Future<T> transaction<T>(
      Future<T> Function(DatabaseService txn) action) async {
    throw UnsupportedError('Nested transactions are not supported');
  }

  @override
  Future<int?> firstIntValue(String sql, [List<dynamic>? arguments]) async {
    final result = txn.select(sql, arguments);
    if (result.isEmpty) return null;
    final firstRow = result.first;
    if (firstRow.isEmpty) return null;
    return firstRow.values.first as int;
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]) async {
    final results = txn.select(sql, arguments);
    return results.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  @override
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    txn.execute(sql, arguments);
    return txn.getUpdatedRows();
  }

  @override
  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    txn.execute(sql, arguments);
    return txn.getUpdatedRows();
  }

  @override
  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    txn.execute(sql, arguments);
    return txn.lastInsertRowId;
  }
}
