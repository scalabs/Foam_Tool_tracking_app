import 'package:alati_app/cubits/tool_fetcher_cubit.dart';
import 'package:alati_app/services/carrier_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';





class CarrierFetcherCubit extends Cubit<FetcherState> {
  final CarriersService service;
  CarrierFetcherCubit(this.service) : super(FetcherLoading()) {
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

