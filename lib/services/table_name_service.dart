import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

abstract class TableNameService {
  Future<String> fetchData();
  Future<void> updateName(String name);
}

class APITableNameService implements TableNameService {
  static const apiBaseUrl = 'http://10.3.41.24:5002/api/';
  //http://10.3.41.24:5002/ ovo je za live
  //http://127.0.0.1:5000/api/'; je za test
  String _tableNameEndpoint = 'table_name_tools';

  set tableNameEndpoint(String s) => _tableNameEndpoint = s;

  @override
  Future<String> fetchData() async {
    final apiUrl = '$apiBaseUrl$_tableNameEndpoint';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        debugPrint('Fetched data: $data');
        return (data.first as Map<String, dynamic>)['name'];
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      throw Exception('Failed to load data');
    }
  }

  @override
  Future<void> updateName(String name) async {
    final apiUrl = '$apiBaseUrl$_tableNameEndpoint';
    await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'name': name,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

class FakeTableNameService implements TableNameService {
  FakeTableNameService();
  @override
  Future<String> fetchData() {
    debugPrint('Function called fetchData');
    return Future.value('Test');
  }

  Future<void> updateName(String name) async {
    debugPrint('Function called updateName');
  }
}
