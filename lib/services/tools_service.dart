import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

abstract class ToolsService {
  Future<List<String>> fetchData(String selectedFilter);
  Future<void> addData(String tool, String filter);
  Future<void> deleteData(String tool, String filter);
}

class APIToolsService implements ToolsService {
  static const apiBaseUrl = 'http://10.3.41.24:5001/api/';
    //http://10.3.41.24:5001/ ovo je za live
  //http://127.0.0.1:5000/api/'; je za test

  @override
  Future<List<String>> fetchData(String selectedFilter) async {
    String filterEndpoint;
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
        filterEndpoint = 'active';
        break;
    }

    final apiUrl = '$apiBaseUrl$filterEndpoint';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        debugPrint('Fetched data: $data');
        return List<String>.from(data.map((item) => item['Alat']));
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      throw Exception('Failed to load data');
    }
  }

@override
Future<void> addData(String tool, String filter) async {
  const apiUrl = '${apiBaseUrl}active';
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'tool': tool,
        'project': filter, // Include other fields if necessary
        // Add more fields here as needed
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Tool added successfully');
    } else {
      print('Failed to add tool: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error adding tool: $e');
  }
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
      headers: {'Content-Type': 'application/json'},
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
}