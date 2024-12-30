// lib/data/storage/drivers/sqlite3_driver.dart

import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'database_driver.dart';

class SQLite3Driver implements DatabaseDriver {
  Database? _database;

  @override
  String get debugLabel => "SQLite3";

  @override
  Future<void> open({
    required String path,
    int? version,
    required Function(dynamic db, int version) onCreate,
    required Function(dynamic db, int oldVersion, int newVersion) onUpgrade,
  }) async {
    debugPrint('[$debugLabel] Opening database at path: $path');
    try {
      _database = sqlite3.open(path);

      // Check if we need to create tables
      final results = _database!.select(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='conversations'"
      );

      if (results.isEmpty) {
        debugPrint('[$debugLabel] Creating database tables');
        await onCreate(_database, version ?? 1);
      } else if (version != null) {
        // Check version and upgrade if needed
        final currentVersion = _database!.select(
            "PRAGMA user_version"
        ).first.values.first as int;

        if (currentVersion < version) {
          await onUpgrade(_database, currentVersion, version);
          _database!.execute("PRAGMA user_version = $version");
        }
      }
    } catch (e) {
      debugPrint('[$debugLabel] Error opening database: $e');
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    _database?.dispose();
    _database = null;
  }

  @override
  Future<void> execute(String query, [List<dynamic>? arguments]) async {
    try {
      var parameterizedQuery = query;
      if (arguments != null && arguments.isNotEmpty) {
        for (var i = 0; i < arguments.length; i++) {
          parameterizedQuery = parameterizedQuery.replaceFirst('?', '\$${i + 1}');
        }
      }

      _database!.execute(parameterizedQuery, arguments?.cast<Object?>() ?? []);
    } catch (e) {
      debugPrint('[$debugLabel] Error in execute query: $query');
      debugPrint('[$debugLabel] With arguments: $arguments');
      debugPrint('[$debugLabel] Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> query(String query, [List<dynamic>? arguments]) async {
    try {
      var parameterizedQuery = query;
      if (arguments != null && arguments.isNotEmpty) {
        for (var i = 0; i < arguments.length; i++) {
          parameterizedQuery = parameterizedQuery.replaceFirst('?', '\$${i + 1}');
        }
      }

      final results = _database!.select(parameterizedQuery, arguments?.cast<Object?>() ?? []);
      return results.map((row) => Map<String, dynamic>.from(row)).toList();
    } catch (e) {
      debugPrint('[$debugLabel] Error in query: $query');
      debugPrint('[$debugLabel] With arguments: $arguments');
      debugPrint('[$debugLabel] Error: $e');
      rethrow;
    }
  }

  @override
  Future<int> insert(String query, [List<dynamic>? arguments]) async {
    _database!.execute(query, arguments?.cast<Object?>() ?? []);
    return _database!.lastInsertRowId;
  }

  @override
  Future<int> update(String query, [List<dynamic>? arguments]) async {
    try {
      var parameterizedQuery = query;
      if (arguments != null && arguments.isNotEmpty) {
        for (var i = 0; i < arguments.length; i++) {
          parameterizedQuery = parameterizedQuery.replaceFirst('?', '\$${i + 1}');
        }
      }

      debugPrint('[$debugLabel] Executing update query: $parameterizedQuery');
      debugPrint('[$debugLabel] With arguments: $arguments');

      _database!.execute(parameterizedQuery, arguments?.cast<Object?>() ?? []);
      return _database!.getUpdatedRows();
    } catch (e) {
      debugPrint('[$debugLabel] Error in update query: $query');
      debugPrint('[$debugLabel] With arguments: $arguments');
      debugPrint('[$debugLabel] Error: $e');
      rethrow;
    }
  }

  @override
  Future<int> delete(String query, [List<dynamic>? arguments]) async {
    _database!.execute(query, arguments?.cast<Object?>() ?? []);
    return _database!.getUpdatedRows();
  }

  @override
  Future<T> transaction<T>(Future<T> Function(dynamic txn) action) async {
    try {
      _database!.execute('BEGIN TRANSACTION');
      final result = await action(_database);
      _database!.execute('COMMIT');
      return result;
    } catch (e) {
      try {
        if (_database != null) {
          _database!.execute('ROLLBACK');
        }
      } catch (rollbackError) {
        debugPrint('Error rolling back transaction: $rollbackError');
      }
      rethrow;
    }
  }

  @override
  Future<int?> firstIntValue(String sql, [List<dynamic>? arguments]) async {
    final result = _database!.select(sql, arguments?.cast<Object?>() ?? []);
    if (result.isEmpty) return null;
    final firstRow = result.first;
    if (firstRow.isEmpty) return null;
    return firstRow.values.first as int;
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    return query(sql, arguments);
  }

  @override
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    return update(sql, arguments);
  }

  @override
  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    return delete(sql, arguments);
  }

  @override
  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    return insert(sql, arguments);
  }
}