import 'package:alati_app/services/tools_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/models/tool_model.dart';

class ToolSelectionCubit extends Cubit<List<Tool?>> {
  final ToolsService service;//So this is for saving the tools (interacting with the api<)
  ToolSelectionCubit(this.service) : super(List<Tool?>.filled(22, null));

  void addTool(int index, String toolName) {
    final updatedTools = List<Tool?>.from(state);

    var angle = (index + 0.5) / 22 * (360);
    updatedTools[index] = Tool(
      toolName, //added this for emails
      'Available',
      DateTime.now(), // Pass the current date and time as the dateAdded
      rotationAngle: angle, // Set rotation angle to 0 initially
    );
    service.addData(toolName, 'Available');
    emit(updatedTools);
  }

  void removeTool(int index) {
    final updatedTools = List<Tool?>.from(state);
    if (updatedTools[index] != null) {
      updatedTools[index]!.rotationAngle =
          0; // Reset rotation angle before removing the tool
      service.deleteData(updatedTools[index]!.name, updatedTools[index]!.status);

    }
    updatedTools[index] = null;
    emit(updatedTools);
  }

  void resizeTable(int newSize) {
    final updatedTools = List<Tool?>.from(state);
    if (newSize > updatedTools.length) {
      updatedTools
          .addAll(List<Tool?>.filled(newSize - updatedTools.length, null));
    } else if (newSize < updatedTools.length) {
      updatedTools.removeRange(newSize, updatedTools.length);
    }
    emit(updatedTools);
  }

  void updateRotationAngle(double delta) {
    final updatedTools = List<Tool?>.from(state);
    for (var tool in updatedTools) {
      if (tool != null) {
        tool.rotationAngle += delta;
      }
    }
    emit(updatedTools);
  }

  void selectNextTool(int itemCount) {}

  void selectPreviousTool(int itemCount) {}

  void updateSelectedIndex(int touchedIndex) {}

  void resetSelection() {}
}
