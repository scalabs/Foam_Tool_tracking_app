import 'dart:convert';
import 'package:alati_app/models/carrier_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

abstract class CarriersAllocationService {
  Future<List<CarrierToolAllocation>> fetchData();
  Future<void> addData(String carrier, int position);
  Future<void> deleteData(String carrier);
}

class APICarriersAllocationService implements CarriersAllocationService {
  static const apiBaseUrl = 'http://10.3.41.24:5002/api/';

  @override
  Future<List<CarrierToolAllocation>> fetchData() async {
    const apiUrl = '${apiBaseUrl}carriers_allocation';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        debugPrint('Fetched data: $data');
        return data.map((e) => CarrierToolAllocation.fromMap(e)).toList();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      throw Exception('Failed to load data');
    }
  }

  @override
  Future<void> addData(String carrier, int position) async {
    const apiUrl = '${apiBaseUrl}carriers_allocation';
    await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'name': carrier,
        'position': position,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  @override
  Future<void> deleteData(String carrier) async {
    const apiUrl = '${apiBaseUrl}carriers_allocation';
    await http.delete(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'name': carrier,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

class FakeCarrierAllocationService implements CarriersAllocationService {
  final int carrierCount;

  FakeCarrierAllocationService({required this.carrierCount});
  @override
  Future<List<CarrierToolAllocation>> fetchData() {
    return Future.value(
      List<CarrierToolAllocation>.generate(
        carrierCount,
        (index) => CarrierToolAllocation(
          name: 'Carrier ${index + 1}',
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
