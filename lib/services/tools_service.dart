import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class ToolsService {
  Future<List<String>> fetchData(String selectedFilter);
  Future<void> addData(String tool, String filter);
  // TODO determine, if this is necessary: Future<void> updateData(String tool, String filter);
  Future<void> deleteData(String tool, String filter);
}

class APIToolsService implements ToolsService {
  static const apiBaseUrl = 'http://127.0.0.1:5000/api/';

  @override
  Future<List<String>> fetchData(String selectedFilter) async {
    String filterEndpoint = '';
    switch (selectedFilter) {
      case 'Tools Cleaned':
        filterEndpoint = 'cleaned';
        break;
      case 'Tools Not Cleaned':
        filterEndpoint = 'not_cleaned';
        break;
      case 'Tools Calibrated':
        filterEndpoint = 'calibrated';
        break;
      case 'Tools Not Calibrated':
        filterEndpoint = 'not_calibrated';
        break;
      default:
        // Fetch all tools if no filter is selected
        break;
    }

    final apiUrl = filterEndpoint.isNotEmpty
        ? '$apiBaseUrl$filterEndpoint'
        : '${apiBaseUrl}active';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      return List<String>.from(data.map((item) => item['Alat']));
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Future<void> addData(String tool, String filter) async {
    const apiUrl = '${apiBaseUrl}active';
    await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'tool': tool,
        'filter': filter,
      }),
    );
  }

  @override
  Future<void> deleteData(String tool, String filter) async {
    const apiUrl = '${apiBaseUrl}active';
    await http.delete(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'tool': tool,
        'filter': filter,
      }),
    );
  }
}

class FakeToolsService implements ToolsService {
  final int toolsCount;

  FakeToolsService({required this.toolsCount});
  @override
  Future<List<String>> fetchData(String selectedFilter) {
    return Future.value(
      List<String>.generate(
        toolsCount,
        (index) => 'Tool ${index + 1}',
      ),
    );
  }

  @override
  Future<void> addData(String tool, String filter) => Future.value();

  @override
  Future<void> deleteData(String tool, String filter) => Future.value();

  // @override
  // Future<void> updateData(String tool, String filter) => Future.value();
}
