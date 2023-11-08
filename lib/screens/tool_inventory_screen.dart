import 'package:flutter/material.dart';

//placeholdr da se importuje alat
class ToolInventoryScreen extends StatefulWidget {
  @override
  _ToolInventoryScreenState createState() => _ToolInventoryScreenState();
}

final List<Tool> tools = [];
final TextEditingController toolNameController = TextEditingController();
final TextEditingController toolConditionController = TextEditingController();

class _ToolInventoryScreenState extends State<ToolInventoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              _showImportDialog(context);
            },
            child: Text('Import Tool'),
          ),
          SizedBox(height: 20),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Import Tool'),
          content: Center(
            child: SizedBox(
              height: 250,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: toolNameController,
                    decoration: InputDecoration(labelText: 'Tool Name'),
                  ),
                  TextField(
                    controller: toolConditionController,
                    decoration: InputDecoration(labelText: 'Tool Condition'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _importTool();
                      Navigator.pop(context);
                    },
                    child: Text('Import'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _importTool() {
    final String toolName = toolNameController.text;
    final String toolCondition = toolConditionController.text;

    if (toolName.isNotEmpty && toolCondition.isNotEmpty) {
      setState(() {
        toolNameController.clear();
        toolConditionController.clear();
      });
    }
  }
}

class Tool {
  final String name;
  final String condition;

  Tool({required this.name, required this.condition});
}
