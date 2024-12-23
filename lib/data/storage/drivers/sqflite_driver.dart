import 'package:chatforge/data/storage/drivers/database_driver.dart';
import 'package:sqflite/sqflite.dart';


class SqfliteDriver implements DatabaseDriver {
  Database? _database;

  @override
  Future<void> open({
    required String path,
    int? version,
    required Function(Database db, int version) onCreate,
    required Function(
        Database db,
        int oldVersion,
        int newVersion,
        ) onUpgrade,
  }) async {
    _database = await openDatabase(
      path,
      version: version,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
    );
  }

  @override
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  @override
  Future<void> execute(String query, [List<dynamic>? arguments]) async {
    await _database!.execute(query, arguments);
  }

  @override
  Future<List<Map<String, dynamic>>> query(String query,
      [List<dynamic>? arguments]) async {
    return await _database!.rawQuery(query, arguments);
  }

  @override
  Future<int> insert(String query, [List<dynamic>? arguments]) async {
    return await _database!.rawInsert(query, arguments);
  }

  @override
  Future<int> update(String query, [List<dynamic>? arguments]) async {
    return await _database!.rawUpdate(query, arguments);
  }

  @override
  Future<int> delete(String query, [List<dynamic>? arguments]) async {
    return await _database!.rawDelete(query, arguments);
  }

  @override
  Future<T> transaction<T>(Future<T> Function(dynamic txn) action) async {
    return await _database!.transaction(action);
  }

  @override
  Future<int?> firstIntValue(String sql, [List<dynamic>? arguments]) async {
    return Sqflite.firstIntValue(await _database!.rawQuery(sql, arguments));
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]) async {
    return _database!.rawQuery(sql, arguments);
  }

  @override
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    return _database!.rawUpdate(sql, arguments);
  }

  @override
  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    return _database!.rawDelete(sql, arguments);
  }

  @override
  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    return _database!.rawInsert(sql, arguments);
  }
}