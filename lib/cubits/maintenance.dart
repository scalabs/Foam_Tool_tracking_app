import 'package:alati_app/services/tools_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ToolFetcherState {}

class ToolsFetcherSuccess extends ToolFetcherState {
  final List<String> tools;

  ToolsFetcherSuccess({required this.tools});
}

class ToolsFetcherLoading extends ToolFetcherState {}

class ToolsFetcherError extends ToolFetcherState {
  final String message;

  ToolsFetcherError({required this.message});
}

class ToolFetcherCubit extends Cubit<ToolFetcherState> {
  final ToolsService service;
  ToolFetcherCubit(this.service) : super(ToolsFetcherLoading()) {
    fetchData('');
  }

  Future<void> fetchData(String selectedFilter) async {
    try {
      emit(ToolsFetcherLoading());
      final resp = await service.fetchData(selectedFilter);
      emit(ToolsFetcherSuccess(tools: resp));
    } catch (e) {
      debugPrint(e.toString());
      emit(ToolsFetcherError(message: e.toString()));
    }
  }
}
