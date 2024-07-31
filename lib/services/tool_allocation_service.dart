import 'dart:convert';
import 'package:alati_app/models/tool_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

abstract class ToolsAllocationService {
  Future<List<ToolAllocation>> fetchData();
  Future<void> addData(String carrier, int position);
  Future<void> deleteData(String carrier);
}

class APIToolsAllocationService implements ToolsAllocationService {
  static const apiBaseUrl = 'http://10.3.41.24:5002/api/';

  @override
  Future<List<ToolAllocation>> fetchData() async {
    const apiUrl = '${apiBaseUrl}tools_allocation';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        debugPrint('Fetched data: $data');
        return data.map((e) => ToolAllocation.fromMap(e)).toList();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      throw Exception('Failed to load data');
    }
  }

  @override
  Future<void> addData(String tool, int position) async {
    const apiUrl = '${apiBaseUrl}tools_allocation';
    await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'name': tool,
        'position': position,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  @override
  Future<void> deleteData(String tool) async {
    const apiUrl = '${apiBaseUrl}tools_allocation';
    await http.delete(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'name': tool,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

class FakeCarrierAllocationService implements ToolsAllocationService {
  final int carrierCount;

  FakeCarrierAllocationService({required this.carrierCount});
  @override
  Future<List<ToolAllocation>> fetchData() {
    return Future.value(
      List<ToolAllocation>.generate(
        carrierCount,
        (index) => ToolAllocation(
          name: 'Tool ${index + 1}',
          position: index,
        ),
      ),
    );
  }

  @override
  Future<void> addData(String tool, int position) => Future.value();

  @override
  Future<void> deleteData(String tool) => Future.value();
}
