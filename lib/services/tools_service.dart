import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class ToolsService {
  Future<List<String>> fetchData(String selectedFilter);
}

class APIToolsService implements ToolsService {
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
        ? 'http://127.0.0.1:5000/api/$filterEndpoint'
        : 'http://127.0.0.1:5000/api/active';

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
}
