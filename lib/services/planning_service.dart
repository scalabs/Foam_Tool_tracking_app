import 'package:alati_app/models/weekly_planning_model.dart';

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
