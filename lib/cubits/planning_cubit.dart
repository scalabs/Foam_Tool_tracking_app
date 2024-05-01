import 'package:alati_app/models/week_of_the_year.dart';
import 'package:alati_app/models/weekly_planning_model.dart';
import 'package:alati_app/services/planning_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PlanningState {}

class PlanningLoading extends PlanningState {}

class PlanningSuccess extends PlanningState {
  final List<WeeklyPlanningModel> models;

  PlanningSuccess({required this.models});
}

class PlanningEmpty extends PlanningState {}

class PlanningError extends PlanningState {
  final String message;

  PlanningError({required this.message});
}

class PlanningCubit extends Cubit<PlanningState> {
  final PlanningService service;
  WeekOfTheYear selectedWeek;
  PlanningCubit({
    required this.selectedWeek,
    required this.service,
  }) : super(PlanningLoading());

  Future<void> selectWeek(WeekOfTheYear selectedWeek) async {
    this.selectedWeek = selectedWeek;
    await init();
  }

  Future<void> init() async {
    try {
      emit(PlanningLoading());
      final models = await service.fetchData();
      emit(PlanningSuccess(models: models));
    } catch (e) {
      emit(PlanningError(message: e.toString()));
    }
  }

  Future<void> updatePlanning(WeeklyPlanningModel model) async {
    try {
      if (state is PlanningSuccess) {
        final currentState = state as PlanningSuccess;

        emit(PlanningSuccess(
          models: currentState.models
              .map((e) => e.id == model.id ? model : e)
              .toList(),
        ));

        await service.updateData(model.id, model);
      } else {
        throw Exception(
          'The current state must be a PlanningSuccess state to be able to update elements',
        );
      }
    } catch (e) {
      emit(PlanningError(message: e.toString()));
    }
  }

  Future<void> addPlanning(WeeklyPlanningModel model) async {
    try {
      if (state is PlanningSuccess) {
        final currentState = state as PlanningSuccess;
        emit(PlanningSuccess(
          models: [
            ...currentState.models,
            model,
          ],
        ));
      } else {
        emit(PlanningSuccess(
          models: [model],
        ));
      }
      await service.addData(model);
    } catch (e) {
      emit(PlanningError(message: e.toString()));
    }
  }
}
