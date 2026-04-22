import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'package:flutter/foundation.dart';

class TursoService {
  static const String _url = 'https://portfolio-hasanabbassorathiya.aws-ap-northeast-1.turso.io/v2/pipeline';
  static const String _token = 'eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJhIjoicnciLCJpYXQiOjE3NzY4OTYxMTEsImlkIjoiMDE5ZGI3NDEtZTQwMS03YTEwLWI4ZjktMWRkNWMwZGFmODJkIiwicmlkIjoiN2U3NjE4ODItZTE2NS00NjRlLWFjOTEtNjdkNThmMTE2MzcyIn0.jtwLWceKGS1rYSDn7khf_AWHHuhqFITuhzALUqhNeKp8d-5D35yq2bwy_AusFQt316GywCfMVN2Q-qsNa2fnDA';

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

class TursoQueryBuilder {
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
          final escaped = v.replaceAll("'", "''");
          return "'$escaped'";
        }
        if (v is bool) return v ? 1 : 0;
        if (v == null) return 'NULL';
        return v.toString();
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
    }

    try {
      final response = await http.post(
        Uri.parse(client.url),
        headers: {
          'Authorization': 'Bearer ${client.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "requests": [
            { "type": "execute", "stmt": { "sql": sql, "args": [] } },
            { "type": "close" }
          ]
        })
      );

      final data = jsonDecode(response.body);
      final execResult = data['results'][0]['response']['result'];
      if (execResult['cols'] == null) return []; // no rows

      final cols = (execResult['cols'] as List).map((c) => c['name'] as String).toList();
      final rows = execResult['rows'] as List;

      return rows.map((row) {
        final map = <String, dynamic>{};
        for (int i = 0; i < cols.length; i++) {
          final cell = row[i];
          final val = cell['value'];
          final type = cell['type'];
          if (type == 'integer') map[cols[i]] = int.tryParse(val.toString()) ?? val;
          else if (type == 'float') map[cols[i]] = double.tryParse(val.toString()) ?? val;
          else map[cols[i]] = val;

          // Boolean conversion since SQLite uses 1/0
          if (cols[i].startsWith('is_')) {
             map[cols[i]] = map[cols[i]] == 1 || map[cols[i]] == '1';
          }
        }
        return map;
      }).toList();
    } catch(e) {
      debugPrint('Turso error: $e');
      throw Exception('Turso execute failed: $e');
    }
  }

  // To allow `await client.from('x').select()` we need to implement Future methods
  // or return a future. A clean way is to implement `then`.
  Future<dynamic> _toFuture() => _execute();

  Future<dynamic> then<R>(Future<R> Function(dynamic value) onValue, {Function? onError}) {
    return _toFuture().then(onValue, onError: onError);
  }

  Future<dynamic> catchError(Function onError, {bool Function(Object)? test}) {
    return _toFuture().catchError(onError, test: test);
  }

  Future<dynamic> whenComplete(Future<void> Function() action) {
    return _toFuture().whenComplete(action);
  }

  Future<dynamic> timeout(Duration timeLimit, {Future<dynamic> Function()? onTimeout}) {
    return _toFuture().timeout(timeLimit, onTimeout: onTimeout);
  }
}