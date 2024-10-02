import 'package:alati_app/models/tool_model.dart';
import 'package:alati_app/services/tool_allocation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AllocationState {}

class AllocationSuccess extends AllocationState {
  final List<ToolAllocation> items;

  AllocationSuccess({required this.items});
}

class AllocationLoading extends AllocationState {}

class AllocationError extends AllocationState {
  final String message;

  AllocationError({required this.message});
}

class ToolsAllocationCubit extends Cubit<AllocationState> {
  final ToolsAllocationService service;
  ToolsAllocationCubit(this.service) : super(AllocationLoading()) {
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      emit(AllocationLoading());
      final resp = await service.fetchData();
      emit(AllocationSuccess(items: resp));
    } catch (e) {
      debugPrint(e.toString());
      emit(AllocationError(message: e.toString()));
    }
  }
}
