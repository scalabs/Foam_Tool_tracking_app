import 'package:alati_app/services/carrier_allocation_service.dart';
import 'package:alati_app/services/carrier_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/models/carrier_model.dart';

class CarrierSelectionCubit extends Cubit<List<Carrier?>> {
  final CarriersService
      service; //So this is for saving the tools (interacting with the api<)
  final CarriersAllocationService allocationService;
  CarrierSelectionCubit(this.service, this.allocationService)
      : super(List<Carrier?>.filled(22, null)) {
    _init();
  }

  Future<void> _init() async {
    final resp = await allocationService.fetchData();
    emit(
      List.generate(
        resp.length < 22 ? 22 : resp.length,
        (index) {
          var angle = (index + 0.5) / 22 * (360);

          final item = resp.singleWhereOrNull(
            (element) => element.position == index,
          );
          if (item == null) {
            return null;
          } else {
            return Carrier(
              item.name,
              'Available',
              DateTime.now(),
              rotationAngle: angle,
            );
          }
        },
      ),
    );
  }

  void addCarrier(int index, String carrierName) {
    final updatedCarriers = List<Carrier?>.from(state);
    var angle = (index + 0.5) / 22 * (360);
    updatedCarriers[index] = Carrier(
      carrierName,
      'Available',
      DateTime.now(),
      rotationAngle: angle,
    );
    service.addData(carrierName, 'Available');
    allocationService.addData(carrierName, index);
    emit(updatedCarriers);
  }

  void removeCarrier(int index) {
    final updatedCarriers = List<Carrier?>.from(state);
    if (updatedCarriers[index] != null) {
      updatedCarriers[index]!.rotationAngle = 0;
      service.deleteData(
          updatedCarriers[index]!.name, updatedCarriers[index]!.status);
      allocationService.deleteData(updatedCarriers[index]!.name);
    }
    updatedCarriers[index] = null;
    emit(updatedCarriers);
  }

  void resizeTable(int newSize) {
    final updatedCarriers = List<Carrier?>.from(state);
    if (newSize > updatedCarriers.length) {
      updatedCarriers.addAll(
          List<Carrier?>.filled(newSize - updatedCarriers.length, null));
    } else if (newSize < updatedCarriers.length) {
      updatedCarriers.removeRange(newSize, updatedCarriers.length);
    }
    emit(updatedCarriers);
  }

  void updateRotationAngle(double delta) {
    final updatedCarriers = List<Carrier?>.from(state);
    for (var carrier in updatedCarriers) {
      if (carrier != null) {
        carrier.rotationAngle += delta;
      }
    }
    emit(updatedCarriers);
  }

  void selectNextCarrier(int itemCount) {}

  void selectPreviousCarrier(int itemCount) {}

  void addTool(int index, String text) {}

  void updateTool(int index, String text) {}

  void updateSelectedIndex(int touchedIndex) {}
}
