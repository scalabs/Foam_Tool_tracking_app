import 'package:flutter_bloc/flutter_bloc.dart';
import '/models/tool_model.dart';

class ToolSelectionCubit extends Cubit<List<Tool?>> {
  ToolSelectionCubit() : super(List.generate(22, (index) => null));

  void addTool(int index, String toolLabel) {
    state[index] = Tool(
      toolLabel,
      '',
    );
    emit(List.from(state));
  }

  void removeTool(int index) {
    state.removeAt(index);
    emit(List.from(state));
  }

  void resizeTable(int size) {
    final newTable = List.generate(size, (index) {
      if (index < state.length) {
        return state[index];
      } else {
        return null;
      }
    });
    emit(newTable);
  }
}
