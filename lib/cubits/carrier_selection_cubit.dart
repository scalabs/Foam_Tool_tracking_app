import 'package:flutter_bloc/flutter_bloc.dart';
import '/models/carrier_model.dart';

class CarrierSelectionCubit extends Cubit<List<Carrier?>> {
  CarrierSelectionCubit() : super(List<Carrier?>.filled(22, null));

  void addCarrier(int index, String carrierName) {
    final updatedCarriers = List<Carrier?>.from(state);
    var angle = (index + 0.5) / 22 * (360);
    updatedCarriers[index] = Carrier(
      carrierName,
      'Available',
      DateTime.now(),
      rotationAngle: angle,
    );
    emit(updatedCarriers);
  }

  void removeCarrier(int index) {
    final updatedCarriers = List<Carrier?>.from(state);
    if (updatedCarriers[index] != null) {
      updatedCarriers[index]!.rotationAngle = 0;
    }
    updatedCarriers[index] = null;
    emit(updatedCarriers);
  }

  void resizeTable(int newSize) {
    final updatedCarriers = List<Carrier?>.from(state);
    if (newSize > updatedCarriers.length) {
      updatedCarriers.addAll(List<Carrier?>.filled(newSize - updatedCarriers.length, null));
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
}
