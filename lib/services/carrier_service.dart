import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

abstract class CarriersService {
  Future<List<String>> fetchData(String selectedFilter);
  Future<void> addData(String carrier, String filter);
  Future<void> deleteData(String carrier, String filter);
}

class APICarriersService implements CarriersService {
  static const apiBaseUrl = 'http://127.0.0.1:5000/api/';

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
        filterEndpoint = 'karijers';
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
        return List<String>.from(data.map((item) => item['Serijski_broj']));
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      throw Exception('Failed to load data');
    }
  }

  @override
  Future<void> addData(String carrier, String filter) async {
    const apiUrl = '${apiBaseUrl}karijers';
    await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'Serijski_broj': carrier,
        'filter': filter,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  @override
  Future<void> deleteData(String carrier, String filter) async {
    const apiUrl = '${apiBaseUrl}karijers';
    await http.delete(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'Serijski_broj': carrier,
        'filter': filter,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

class FakeCarrierService implements CarriersService {
  final int carrierCount;

  FakeCarrierService({required this.carrierCount});
  @override
  Future<List<String>> fetchData(String selectedFilter) {
    return Future.value(
      List<String>.generate(
        carrierCount,
        (index) => 'Carrier ${index + 1}',
      ),
    );
  }

  @override
  Future<void> addData(String tool, String filter) => Future.value();

  @override
  Future<void> deleteData(String tool, String filter) => Future.value();
}
