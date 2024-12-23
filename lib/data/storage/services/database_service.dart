import 'package:chatforge/data/storage/drivers/database_driver.dart';
import 'package:sqflite/sqflite.dart';

/// Abstract class defining the interface for database operations.
abstract class DatabaseService {
  Future<void> initialize();

  Future<void> execute(String query, [List<dynamic>? arguments]);

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
      });

  Future<int> insert(String table, Map<String, dynamic> values);

  Future<int> update(
      String table,
      Map<String, dynamic> values, {
        String? where,
        List<dynamic>? whereArgs,
      });

  Future<int> delete(
      String table, {
        String? where,
        List<dynamic>? whereArgs,
      });

  Future<T> transaction<T>(Future<T> Function(DatabaseService txn) action);

  Future<int?> firstIntValue(String sql, [List<dynamic>? arguments]);

  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]);

  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]);

  Future<int> rawDelete(String sql, [List<dynamic>? arguments]);

  Future<int> rawInsert(String sql, [List<dynamic>? arguments]);
}