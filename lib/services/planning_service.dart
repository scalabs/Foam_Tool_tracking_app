import 'package:alati_app/models/weekly_planning_model.dart';

abstract class PlanningService {
  Future<List<WeeklyPlanningModel>> fetchData();
  Future<void> addData(int id);
  Future<void> updateData(int id);
  Future<void> deleteData(int id);
}

class FakePlanningService implements PlanningService {
  @override
  Future<void> addData(int id) => Future.value();

  @override
  Future<void> deleteData(int id) => Future.value();

  @override
  Future<List<WeeklyPlanningModel>> fetchData() => Future.value([]);

  @override
  Future<void> updateData(int id) => Future.value();
}
