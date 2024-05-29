import 'dart:math';
import 'package:alati_app/cubits/tool_fetcher_cubit.dart';
import 'package:alati_app/cubits/tool_selection_cubit.dart';
import 'package:alati_app/models/tool_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final List<String> filterOptions = [
    'All',
    'Tools Cleaned',
    'Tools Not Cleaned',
    'Tools Calibrated',
    'Tools Not Calibrated',
  ];

  String selectedFilter = 'All';
  final TextEditingController _controller = TextEditingController();
  late SharedPreferences prefs;

  @override
  void initState() {
    _loadSavedTableName();
    super.initState();
  }

  Future<void> _loadSavedTableName() async {
    prefs = await SharedPreferences.getInstance();
    final savedTableName = prefs.getString('tableName') ?? 'Table 1';
    setState(() {
      _controller.text = savedTableName;
    });
  }

  Future<void> _saveTableName(String tableName) async {
    await prefs.setString('tableName', tableName);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToolSelectionCubit, List<Tool?>>(
      builder: (context, state) {
        return GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              context.read<ToolSelectionCubit>().updateRotationAngle(details.delta.dx);
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildFilterColumn(context),
              const SizedBox(width: 16), // Added space between column and pie chart
              _buildPieChart(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterColumn(BuildContext context) {
    return Column(
      children: [
        _buildFilterHeader(),
        const SizedBox(height: 8),
        _buildFilterDropdown(context),
        const SizedBox(height: 16),
        _buildToolList(context),
      ],
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Text(
        'Filter Tool State',
        style: TextStyle(fontSize: 18.0, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterDropdown(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          value: selectedFilter,
          onChanged: (String? value) {
            setState(() {
              selectedFilter = value!;
              context.read<ToolFetcherCubit>().fetchData(selectedFilter);
            });
          },
          items: filterOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildToolList(BuildContext context) {
    return SizedBox(
      height: 800,
      width: 200,
      child: BlocBuilder<ToolFetcherCubit, ToolFetcherState>(
        builder: (context, fetcherState) {
          if (fetcherState is ToolsFetcherSuccess) {
            final tools = fetcherState.tools;
            if (tools.isNotEmpty) {
              return ListView.builder(
                itemCount: tools.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(tools[index]),
                    onTap: () {
                      showAddToolDialog(context, index, tools);
                    },
                  );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, List<Tool?> state) {
    return Expanded(
      child: InteractiveViewer(
        child: Stack(
          children: [
            Center(
              child: Text(
                _controller.text,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            LayoutBuilder(builder: (context, constraints) {
              final size = constraints.maxWidth - 1065;
              return Center(
                child: SizedBox(
                  width: size,
                  height: size,
                  child: GestureDetector(
                    onTap: () {},
                    child: Stack(
                      children: [
                        _buildPieChartSections(context, state, size),
                      ],
                    ),
                  ),
                ),
              );
            }),
            _buildPieChartControls(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartSections(BuildContext context, List<Tool?> state, double size) {
    return PieChart(
      PieChartData(
        sections: List.generate(state.length, (index) {
          final tool = state[index];
          final isOverdue = tool != null && DateTime.now().difference(tool.dateAdded).inDays >= 3;
          return PieChartSectionData(
            color: isOverdue ? Colors.red : Colors.blue[300],
            value: 1,
            title: '',
            radius: size / 2,
            badgeWidget: tool != null
                ? _buildToolBadge(context, index, tool)
                : _buildAddToolIcon(context, index),
            badgePositionPercentageOffset: 0.5,
          );
        }),
        centerSpaceRadius: 100,
        sectionsSpace: 6,
        startDegreeOffset: 180,
      ),
    );
  }

  Widget _buildToolBadge(BuildContext context, int index, Tool tool) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          tool.rotationAngle += details.delta.dx;
        });
      },
      child: Transform.rotate(
        angle: tool.rotationAngle * pi / 180,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${index + 1}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                context.read<ToolSelectionCubit>().removeTool(index);
              },
              icon: const Icon(Icons.remove_circle_outline_outlined),
            ),
            Center(
              child: Text(
                tool.name,
                style: const TextStyle(fontSize: 24, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToolIcon(BuildContext context, int index) {
    return BlocBuilder<ToolFetcherCubit, ToolFetcherState>(
      builder: (context, fetcherState) {
        if (fetcherState is ToolsFetcherSuccess) {
          final tools = fetcherState.tools;
          return IconButton(
            onPressed: () {
              showAddToolDialog(context, index, tools);
            },
            icon: const Icon(Icons.add_circle_outline_outlined),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildPieChartControls(BuildContext context, List<Tool?> state) {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(12),
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              onChanged: (v) {
                _saveTableName(v);
                setState(() {});
              },
              decoration: const InputDecoration(helperText: 'Roundtable name'),
            ),
            Slider(
              value: (state.length / 40),
              onChanged: (v) {
                final newLength = (v * 40).toInt().clamp(1, 40);
                context.read<ToolSelectionCubit>().resizeTable(newLength);
              },
            ),
            Text(
              'Number of sections: ${state.length}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void showAddToolDialog(BuildContext context, int sectionIndex, List<String> tools) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a tool to section $sectionIndex'),
          content: SizedBox(
            height: 400,
            width: 100,
            child: ListView.builder(
              itemCount: tools.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(tools[index]),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ToolSelectionCubit>().addTool(sectionIndex, tools[index]);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
