import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'package:flutter/foundation.dart';

class TursoService {
  static String get _url => AppConfig.tursoUrl;
  static String get _token => AppConfig.tursoToken;

  static TursoClient? _client;

  static Future<void> initialize() async {
    _client = TursoClient(_url, _token);
  }

  static TursoClient? get client => _client;
  static TursoClient get requiredClient => _client!;
  static bool get isInitialized => _client != null;
  static dynamic get auth => null; // Mock auth if needed
  static dynamic get storage => null; // Mock storage if needed
}

class TursoClient {
  final String url;
  final String token;

  TursoClient(this.url, this.token);

  TursoQueryBuilder from(String table) {
    return TursoQueryBuilder(this, table);
  }
}

class TursoQueryBuilder implements Future<dynamic> {
  final TursoClient client;
  final String table;
  String _action = '';
  List<String> _selectCols = ['*'];
  List<String> _where = [];
  List<String> _order = [];
  int? _limit;
  int? _offset;
  Map<String, dynamic>? _insertData;

  TursoQueryBuilder(this.client, this.table);

  TursoQueryBuilder select([String columns = '*']) {
    _action = 'select';
    _selectCols = [columns];
    return this;
  }

  TursoQueryBuilder insert(Map<String, dynamic> data) {
    _action = 'insert';
    _insertData = data;
    return this;
  }

  TursoQueryBuilder upsert(Map<String, dynamic> data) {
    _action = 'upsert';
    _insertData = data;
    return this;
  }

  TursoQueryBuilder update(Map<String, dynamic> data) {
    _action = 'update';
    _insertData = data;
    return this;
  }

  TursoQueryBuilder delete() {
    _action = 'delete';
    return this;
  }

  // Add this method to allow empty deletes
  TursoQueryBuilder deleteAll() {
    _action = 'delete';
    _where.clear(); // Clear all where clauses
    return this;
  }

  TursoQueryBuilder eq(String column, dynamic value) {
    if (value is String) {
      _where.add("$column = '$value'");
    } else if (value is bool) {
      _where.add("$column = ${value ? 1 : 0}");
    } else {
      _where.add("$column = $value");
    }
    return this;
  }

  TursoQueryBuilder gte(String column, dynamic value) {
    if (value is String) {
      _where.add("$column >= '$value'");
    } else {
      _where.add("$column >= $value");
    }
    return this;
  }

  TursoQueryBuilder lte(String column, dynamic value) {
    if (value is String) {
      _where.add("$column <= '$value'");
    } else {
      _where.add("$column <= $value");
    }
    return this;
  }

  TursoQueryBuilder not(String column, String operator, dynamic value) {
    String op = '=';
    if (operator == 'eq') op = '!=';
    else if (operator == 'gt') op = '<=';
    else if (operator == 'lt') op = '>=';

    if (value is String) {
      _where.add("$column $op '$value'");
    } else {
      _where.add("$column $op $value");
    }
    return this;
  }

  TursoQueryBuilder order(String column, {bool ascending = false}) {
    _order.add("$column ${ascending ? 'ASC' : 'DESC'}");
    return this;
  }

  TursoQueryBuilder limit(int count) {
    _limit = count;
    return this;
  }

  TursoQueryBuilder range(int from, int to) {
    _offset = from;
    _limit = to - from + 1;
    return this;
  }

  Future<dynamic> single() async {
    _limit = 1;
    final res = await _execute();
    if (res is List && res.isNotEmpty) return res.first;
    throw Exception('No rows found');
  }

  Future<dynamic> maybeSingle() async {
    _limit = 1;
    final res = await _execute();
    if (res is List && res.isNotEmpty) return res.first;
    return null;
  }

  Future<dynamic> _execute() async {
    String sql = '';
    if (_action == 'select') {
      sql = 'SELECT ${_selectCols.join(', ')} FROM $table';
      debugPrint('Generated SQL: $sql');
      if (_where.isNotEmpty) {
        sql += ' WHERE ${_where.join(' AND ')}';
      }
      if (_order.isNotEmpty) {
        sql += ' ORDER BY ${_order.join(', ')}';
      }
      if (_limit != null) {
        sql += ' LIMIT $_limit';
      }
      if (_offset != null) {
        sql += ' OFFSET $_offset';
      }
    } else if (_action == 'insert' || _action == 'upsert') {
      final cols = _insertData!.keys.join(', ');
      final vals = _insertData!.values.map((v) {
        if (v is String) {
          final escaped = v.replaceAll("'", "''")
                           .replaceAll("\n", " ")
                           .replaceAll("\\", "\\\\");
          return "'$escaped'";
        }
        if (v is bool) return v ? 1 : 0;
        if (v is Map) {
          final jsonStr = jsonEncode(v).replaceAll("'", "''");
          return "'$jsonStr'";
        }
        if (v == null) return 'NULL';
        return "'${v.toString().replaceAll("'", "''")}'";
      }).join(', ');
      final replace = _action == 'upsert' ? 'OR REPLACE ' : '';
      sql = 'INSERT ${replace}INTO $table ($cols) VALUES ($vals)';
    } else if (_action == 'update') {
      final sets = _insertData!.entries.map((e) {
        final v = e.value;
        String valStr;
        if (v is String) {
          final escaped = v.replaceAll("'", "''");
          valStr = "'$escaped'";
        }
        else if (v is bool) valStr = v ? '1' : '0';
        else if (v == null) valStr = 'NULL';
        else valStr = v.toString();
        return '${e.key} = $valStr';
      }).join(', ');
      sql = 'UPDATE $table SET $sets';
      if (_where.isNotEmpty) {
        sql += ' WHERE ${_where.join(' AND ')}';
      }
    } else if (_action == 'delete') {
      sql = 'DELETE FROM $table';
      if (_where.isNotEmpty) {
        sql += ' WHERE ${_where.join(' AND ')}';
      }
    }

    debugPrint('Executing SQL: $sql');

    final body = jsonEncode({
      "requests": [
        { "type": "execute", "stmt": { "sql": sql, "args": [] } },
        { "type": "close" }
      ]
    });
    debugPrint('TursoService: Request Body: $body');

    debugPrint('TursoService: SQL to be executed: $sql');

    try {
      final response = await http.post(
        Uri.parse(client.url),
        headers: {
          'Authorization': 'Bearer ${client.token}',
          'Content-Type': 'application/json',
        },
        body: body
      );

      debugPrint('Turso Raw Response: ${response.body}');

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        debugPrint('Turso error body: ${response.body}');
        throw Exception('Failed to parse response. Status: \${response.statusCode}, Body: \${response.body.length > 200 ? response.body.substring(0, 200) : response.body}, SQL: \$sql');
      }
      final results = data['results'] as List?;
      if (results == null || results.isEmpty) throw Exception('No results');
      final resultObj = results[0] as Map<String, dynamic>?;
      if (resultObj == null) throw Exception('Result object is null');
      if (resultObj['type'] == 'error') {
        throw Exception(resultObj['error']['message']);
      }
      final res = resultObj['response'] as Map<String, dynamic>?;
      if (res == null) throw Exception('Response is null');
      final execResult = res['result'] as Map<String, dynamic>?;
      if (execResult == null) {
        debugPrint('Turso Error: execResult is null');
        return [];
      }

      debugPrint('Turso execResult cols: ${execResult['cols']}');
      debugPrint('Turso execResult rows: ${execResult['rows']?.length} rows found');

      if (execResult['cols'] == null || execResult['rows'] == null) {
        debugPrint('Turso Error: cols or rows is null');
        return [];
      }

      final cols = (execResult['cols'] as List).map((c) => c['name'] as String).toList();
      final rows = execResult['rows'] as List;

      final parsedRows = rows.map((row) {
        final map = <String, dynamic>{};
        for (int i = 0; i < cols.length; i++) {
          try {
            final cell = row[i] as Map;
            final val = cell['value'];
            final type = cell['type'];

            if (type == 'integer') {
              map[cols[i]] = val is int ? val : int.tryParse(val.toString());
            } else if (type == 'float') {
              map[cols[i]] = val is double ? val : double.tryParse(val.toString());
            } else if (type == 'null') {
              map[cols[i]] = null;
            } else {
              map[cols[i]] = val;
            }

            // Boolean conversion since SQLite uses 1/0
            if (cols[i].startsWith('is_')) {
               final v = map[cols[i]];
               map[cols[i]] = v == 1 || v == '1' || v == true || v == 'true';
            }
          } catch (e) {
            debugPrint('TursoService: Error parsing cell at column ${cols[i]}: $e');
            map[cols[i]] = null;
          }
        }
        return map;
      }).toList();

      debugPrint('Turso parsed ${parsedRows.length} rows successfully');
      return parsedRows;
    } catch(e, stack) {
      debugPrint('Turso error: $e');
      debugPrint('Turso stack trace: $stack');
      throw Exception('Turso execute failed: $e');
    }
  }

  Future<dynamic> _toFuture() => _execute();

  @override
  Future<R> then<R>(FutureOr<R> Function(dynamic value) onValue, {Function? onError}) {
    return _toFuture().then(onValue, onError: onError);
  }

  @override
  Future<dynamic> catchError(Function onError, {bool Function(Object)? test}) {
    return _toFuture().catchError(onError, test: test);
  }

  @override
  Future<dynamic> whenComplete(FutureOr<void> Function() action) {
    return _toFuture().whenComplete(action);
  }

  @override
  Stream<dynamic> asStream() {
    return Stream.fromFuture(_toFuture());
  }

  @override
  Future<dynamic> timeout(Duration timeLimit, {dynamic Function()? onTimeout}) {
    return _toFuture().timeout(timeLimit, onTimeout: onTimeout);
  }
}