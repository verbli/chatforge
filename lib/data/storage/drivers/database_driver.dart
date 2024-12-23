
abstract class DatabaseDriver {
  Future<void> open({
    required String path,
    int? version,
    required Function(dynamic db, int version) onCreate,
    required Function(
        dynamic db,
        int oldVersion,
        int newVersion,
        ) onUpgrade,
  });

  Future<void> close();

  Future<void> execute(String query, [List<dynamic>? arguments]);

  Future<List<Map<String, dynamic>>> query(String query,
      [List<dynamic>? arguments]);

  Future<int> insert(String query, [List<dynamic>? arguments]);

  Future<int> update(String query, [List<dynamic>? arguments]);

  Future<int> delete(String query, [List<dynamic>? arguments]);

  Future<T> transaction<T>(Future<T> Function(dynamic txn) action);

  Future<int?> firstIntValue(String sql, [List<dynamic>? arguments]);

  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]);

  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]);

  Future<int> rawDelete(String sql, [List<dynamic>? arguments]);

  Future<int> rawInsert(String sql, [List<dynamic>? arguments]);
}