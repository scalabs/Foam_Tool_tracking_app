import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class ToolFetcherCubit extends Cubit<List<String>> {
  ToolFetcherCubit() : super([]);

  Future<void> fetchData(String selectedFilter) async {
    //emit(['Tool 1', 'Tool 2', 'Tool 3', 'Tool 4']);
    //return;
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

    String apiUrl = filterEndpoint.isNotEmpty
        ? 'http://127.0.0.1:5000/api/$filterEndpoint'
        : 'http://127.0.0.1:5000/api/active';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      emit(List<String>.from(data.map((item) => item['Alat'])));
    } else {
      debugPrint('Failed to load data');
    }
  }
}
