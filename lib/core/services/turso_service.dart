import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class TursoService {
  static String? _url;
  static String? _token;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    _url = AppConfig.tursoUrl;
    _token = AppConfig.tursoToken;
    _initialized = true;
  }

  static Future<List<Map<String, dynamic>>> query(String sql) async {
    if (!_initialized) throw Exception('TursoService not initialized');

    final response = await http.post(
      Uri.parse(_url!),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'requests': [
          {'type': 'execute', 'stmt': {'sql': sql, 'args': []}},
          {'type': 'close'},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Turso request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final results = data['results'] as List?;
    if (results == null || results.isEmpty) return [];

    final result = results[0];
    if (result['type'] == 'error') {
      throw Exception(result['message'] ?? 'Unknown Turso error');
    }

    final response_ = result['response'];
    final result_ = response_['result'];
    final cols = result_['cols'] as List;
    final rows = result_['rows'] as List;

    return rows.map<Map<String, dynamic>>((row) {
      final map = <String, dynamic>{};
      for (var i = 0; i < cols.length; i++) {
        final colName = cols[i]['name'] ?? 'col_$i';
        final cell = row[i];
        map[colName] = cell['value'];
      }
      return map;
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> select(
    String table, {
    String? where,
    String? orderBy,
    int? limit,
  }) async {
    var sql = 'SELECT * FROM $table';
    if (where != null) sql += ' WHERE $where';
    if (orderBy != null) sql += ' ORDER BY $orderBy';
    if (limit != null) sql += ' LIMIT $limit';
    return query(sql);
  }

  static Future<void> insert(String table, Map<String, dynamic> data) async {
    final cols = data.keys.join(', ');
    final vals = data.values.map(_escapeVal).join(', ');
    await query('INSERT INTO $table ($cols) VALUES ($vals)');
  }

  static Future<void> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
  }) async {
    final sets = data.entries.map((e) => "${e.key} = ${_escapeVal(e.value)}").join(', ');
    await query('UPDATE $table SET $sets WHERE $where');
  }

  static Future<void> delete(String table, {required String where}) async {
    await query('DELETE FROM $table WHERE $where');
  }

  static String _escapeVal(dynamic value) {
    if (value == null) return 'NULL';
    if (value is bool) return value ? '1' : '0';
    if (value is int || value is double) return value.toString();
    if (value is List) return "'${jsonEncode(value)}'";
    return "'${value.toString().replaceAll("'", "''")}'";
  }
}
