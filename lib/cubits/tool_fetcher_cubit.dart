import 'package:alati_app/services/tools_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetcherState {}

class FetcherSuccess extends FetcherState {
  final List<String> items;

  FetcherSuccess({required this.items});
}

class FetcherLoading extends FetcherState {}

class FetcherError extends FetcherState {
  final String message;

  FetcherError({required this.message});
}

class ToolFetcherCubit extends Cubit<FetcherState> {
  final ToolsService service;
  ToolFetcherCubit(this.service) : super(FetcherLoading()) {
    fetchData('');
  }

  Future<void> fetchData(String selectedFilter) async {
    try {
      emit(FetcherLoading());
      final resp = await service.fetchData(selectedFilter);
      emit(FetcherSuccess(items: resp));
    } catch (e) {
      debugPrint(e.toString());
      emit(FetcherError(message: e.toString()));
    }
  }
}