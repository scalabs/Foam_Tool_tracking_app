import 'package:alati_app/cubits/tool_fetcher_cubit.dart';
import 'package:alati_app/cubits/tool_selection_cubit.dart';
import 'package:alati_app/models/tool_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

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

  final _controller = TextEditingController();
  late SharedPreferences prefs;

  @override
  void initState() {
    _loadSavedTableName();
    super.initState();
  }

// TODO put in cubit
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
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 250,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: selectedFilter,
                  onChanged: (String? value) {
                    setState(() {
                      selectedFilter = value!;
                      context.read<ToolFetcherCubit>().fetchData(
                            selectedFilter,
                          ); // Fetch data again when filter changes
                    });
                  },
                  items: filterOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const VerticalDivider(),
            SizedBox(
              width: 250,
              child: BlocBuilder<ToolFetcherCubit, ToolFetcherState>(
                builder: (context, state) {
                  if (state is ToolsFetcherSuccess) {
                    final tools = state.tools;
                    if (tools.isNotEmpty) {
                      return ListView.builder(
                        itemCount: tools.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(tools[index]),
                            onTap: () {
                              showAddToolDialog(index, tools);
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
            ),
            const VerticalDivider(),
            Expanded(
              child: InteractiveViewer(
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        _controller.text,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    LayoutBuilder(builder: (context, constraints) {
                      final size = constraints.maxWidth - 200;
                      return Center(
                        child: SizedBox(
                          width: size,
                          height: size,
                          child: DragTarget<String>(
                            builder: (context, candidateData, rejectedData) {
                              return PieChart(
                                PieChartData(
                                  sections: state.asMap().entries.map(
                                    (e) {
                                      var tool = e.value;
                                      return PieChartSectionData(
                                        color: Colors.blue[300],
                                        value: 1,
                                        title: tool?.name ??
                                            (e.key + 1).toString(),
                                        radius: size / 2,
                                        titlePositionPercentageOffset: 0.6,
                                        badgeWidget: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: BlocBuilder<ToolFetcherCubit,
                                              ToolFetcherState>(
                                            builder: (context, state) {
                                              if (state
                                                  is ToolsFetcherSuccess) {
                                                final tools = state.tools;
                                                return IconButton(
                                                  onPressed: () {
                                                    showAddToolDialog(
                                                      e.key,
                                                      tools,
                                                    );
                                                  },
                                                  icon: tool == null
                                                      ? const Icon(Icons
                                                          .add_circle_outline_outlined)
                                                      : const Icon(Icons
                                                          .remove_circle_outline_outlined),
                                                );
                                              } else {
                                                return const CircularProgressIndicator();
                                              }
                                            },
                                          ),
                                        ),
                                        badgePositionPercentageOffset: 0.85,
                                      );
                                    },
                                  ).toList(),
                                  centerSpaceRadius: 100,
                                  sectionsSpace: 6,
                                  startDegreeOffset: 180,
                                ),
                              );
                            },
                            onWillAcceptWithDetails: (data) {
                              return true;
                            },
                            onAcceptWithDetails: (data) {
                              removeItem(data.data);
                            },
                          ),
                        ),
                      );
                    }),
                    Positioned(
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
                              decoration: const InputDecoration(
                                  helperText: 'Roundtable name'),
                            ),
                            Slider(
                              value: (state.length / 40),
                              onChanged: (v) {
                                final newLength = (v * 40).toInt().clamp(1, 40);
                                context
                                    .read<ToolSelectionCubit>()
                                    .resizeTable(newLength);
                              },
                            ),
                            Text(
                              'Number of sections: ${state.length}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showAddToolDialog(int sectionIndex, List<String> tools) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a tool to section $sectionIndex'),
          content: SizedBox(
            height: 350, // Adjust the height as needed
            width: 250,
            child: ListView.builder(
              itemBuilder: (context, index) => ListTile(
                title: Text(tools[index]),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  context
                      .read<ToolSelectionCubit>()
                      .addTool(sectionIndex, tools[index]);
                },
              ),
              itemCount: tools.length,
            ),
          ),
        );
      },
    );
  }

  void removeItem(String item) {
    setState(() {
      filterOptions.remove(item);
    });
  }
}
