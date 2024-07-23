import 'dart:convert';

import 'package:alati_app/models/weekly_planning_model.dart';
import 'package:http/http.dart' as http;


abstract class PlanningService {
  Future<List<WeeklyPlanningModel>> fetchData();
  Future<void> addData(WeeklyPlanningModel model);
  Future<void> updateData(int id, WeeklyPlanningModel model);
  Future<void> deleteData(int id);
}

class FakePlanningService implements PlanningService {
  @override
  Future<void> addData(WeeklyPlanningModel model) => Future.value();

  @override
  Future<void> deleteData(int id) => Future.value();

  @override
  Future<List<WeeklyPlanningModel>> fetchData() => Future.value([]);

  @override
  Future<void> updateData(int id, WeeklyPlanningModel model) => Future.value();

}

class ApiPlanningService implements PlanningService {
  @override
  Future<void> addData(WeeklyPlanningModel model) async {
    http.put(
      Uri.parse('http://10.3.41.24:5002/api/weekly_shifts'),
      //10.3.41.24 for live 
      //127.0.0.1:5000 for test
      body:jsonEncode(model.toMap()),);
  }

  @override
  Future<void> deleteData(int id) async {
    http.delete(
      Uri.parse('http://10.3.41.24:5002/api/weekly_shifts/$id'));
  }

  @override
  Future<List<WeeklyPlanningModel>> fetchData () async {
    final response = await http.get(
      Uri.parse('http://10.3.41.24:5002/api/weekly_shifts'),
      );
    final json = jsonDecode(response.body) as List;
    return json.map((e) => WeeklyPlanningModel.fromMap(e)).toList();
  }

  @override
  Future<void> updateData(int id, WeeklyPlanningModel model) async {
    http.put(
      Uri.parse('http://10.3.41.24:5002/api/weekly_shifts/$id'),
      body:jsonEncode(model.toMap()),);
  }
  
}
