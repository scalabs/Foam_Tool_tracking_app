import 'dart:math';
import 'package:alati_app/cubits/carrier_fetcher_cubit.dart';
import 'package:alati_app/cubits/carrier_selection_cubit.dart';
import 'package:alati_app/cubits/tool_fetcher_cubit.dart';
import 'package:alati_app/cubits/tool_selection_cubit.dart';
import 'package:alati_app/models/carrier_model.dart';
import 'package:alati_app/models/tool_model.dart';
import 'package:alati_app/services/carrier_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

String only(String string, int max) =>
    max >= (string.length - 1) ? string : string.substring(0, max);

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
  final TextEditingController _controller = TextEditingController();
  late SharedPreferences prefs;

  bool showTools = true; // State to toggle between tools and carriers
  CarriersService apiService = APICarriersService();

  double rotation = 0;

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
      builder: (context, toolState) {
        return BlocBuilder<CarrierSelectionCubit, List<Carrier?>>(
          builder: (context, carrierState) {
            return Scaffold(
              key: UniqueKey(),
              body: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    if (showTools) {
                      context
                          .read<ToolSelectionCubit>()
                          .updateRotationAngle(details.delta.dx);
                    } else {
                      context
                          .read<CarrierSelectionCubit>()
                          .updateRotationAngle(details.delta.dx);
                    }
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildFilterColumn(context),
                    const SizedBox(
                      width: 16,
                    ), // Added space between column and pie chart
                    showTools
                        ? _buildPieChart(context, toolState, true)
                        : _buildPieChart(context, carrierState, false),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    showTools = !showTools;
                  });
                  if (showTools) {
                    context.read<ToolFetcherCubit>().fetchData(selectedFilter);
                  } else {
                    context
                        .read<CarrierFetcherCubit>()
                        .fetchData(selectedFilter);
                  }
                },
                tooltip: showTools ? 'Switch to Carriers' : 'Switch to Tools',
                child: Icon(showTools ? Icons.build : Icons.local_shipping),
              ),
            );
          },
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
        if (showTools)
          _buildToolList(context, context.read<ToolFetcherCubit>()),
        if (!showTools)
          _buildToolList<CarrierFetcherCubit>(
              context, context.read<CarrierFetcherCubit>()),
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
            });
            if (showTools) {
              context.read<ToolFetcherCubit>().fetchData(selectedFilter);
            } else {
              context.read<CarrierFetcherCubit>().fetchData(selectedFilter);
            }
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

  Widget _buildToolList<T>(BuildContext context, Cubit c) {
    return SizedBox(
      height: 800,
      width: 200,
      child: BlocBuilder(
        bloc: c,
        builder: (context, fetcherState) {
          if (fetcherState is FetcherSuccess) {
            final tools = fetcherState.items;
            if (tools.isNotEmpty) {
              return ListView.builder(
                itemCount: tools.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(tools[index]),
                    onTap: () {
                      showAddToolDialog(context, index, tools.cast<String>());
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

  Widget _buildPieChart(
      BuildContext context, List<dynamic> state, bool isTool) {
    return Expanded(
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
              final size = constraints.maxWidth - 1065;
              return Center(
                  child: SizedBox(
                width: size,
                height: size,
                child: GestureDetector(
                  onTap: () {},
                  child: Stack(
                    children: [
                      _buildPieChartSections(context, state, size, isTool),
                    ],
                  ),
                ),
              ));
            }),
            _buildPieChartControls(context, state, isTool),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartSections(
      BuildContext context, List<dynamic> state, double size, bool isTool) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          rotation += details.delta.dx;
        });
        print(rotation);
      },
      child: Transform.rotate(
        angle: rotation,
        child: PieChart(
          PieChartData(
            sections: List.generate(state.length, (index) {
              final item = state[index];
              final isOverdue = item != null &&
                  DateTime.now().difference(item.dateAdded).inDays >= 3;
              return PieChartSectionData(
                color: isOverdue
                    ? Colors.red
                    : (isTool ? Colors.blue[300] : Colors.green[300]),
                value: 1,
                title: '',
                radius: size / 2,
                badgeWidget: Stack(
                  children: [
                    Center(
                      child: item != null
                          ? _buildBadge(context, index, item, isTool)
                          : _buildAddIcon(context, index, isTool),
                    ),
                    Center(
                      child: Transform.rotate(
                        angle: () {
                          var angle = (index + 0.5) / 22 * (2 * pi);
                          return angle;
                        }(),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 420,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                badgePositionPercentageOffset: 0.5,
              );
            }),
            centerSpaceRadius: 100,
            sectionsSpace: 6,
            startDegreeOffset: 180,
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
      BuildContext context, int index, dynamic item, bool isTool) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          item.rotationAngle += details.delta.dx;
        });
      },
      child: Transform.rotate(
        angle: item.rotationAngle * pi / 180,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                if (isTool) {
                  context.read<ToolSelectionCubit>().removeTool(index);
                } else {
                  context.read<CarrierSelectionCubit>().removeCarrier(index);
                }
              },
              icon: const Icon(Icons.remove_circle_outline_outlined),
            ),
            Center(
              child: Text(
                only(item.name, 20),
                style: const TextStyle(fontSize: 24, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddIcon(BuildContext context, int index, bool isTool) {
    final cubit = isTool
        ? context.read<ToolFetcherCubit>()
        : context.read<CarrierFetcherCubit>();
    return BlocBuilder(
      bloc: cubit,
      builder: (context, fetcherState) {
        if (fetcherState is FetcherSuccess) {
          final items = fetcherState.items;
          return IconButton(
            onPressed: () {
              if (isTool) {
                showAddToolDialog(context, index, items.cast<String>());
              } else {
                showAddCarrierDialog(context, index, items.cast<String>());
              }
            },
            icon: const Icon(Icons.add_circle_outline_outlined),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildPieChartControls(
      BuildContext context, List<dynamic> state, bool isTool) {
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
                if (isTool) {
                  context.read<ToolSelectionCubit>().resizeTable(newLength);
                } else {
                  context.read<CarrierSelectionCubit>().resizeTable(newLength);
                }
              },
            ),
            Text(
              'Number of sections: ${state.length}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const Divider(),
            Slider(
              value: (rotation / (2 * pi) * 360).clamp(0, 720.0),
              max: 720.0,
              min: 0,
              divisions: 5,
              onChanged: (v) {
                setState(() {
                  rotation = v / 360 * (2 * pi);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void showAddToolDialog(
      BuildContext context, int sectionIndex, List<String> tools) {
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
                  context
                      .read<ToolSelectionCubit>()
                      .addTool(sectionIndex, tools[index]);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

void showAddCarrierDialog(
    BuildContext context, int sectionIndex, List<String> carriers) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Add a carrier to section $sectionIndex'),
        content: SizedBox(
          height: 400,
          width: 100,
          child: ListView.builder(
            itemCount: carriers.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(carriers[index]),
              onTap: () {
                Navigator.pop(context);
                context
                    .read<CarrierSelectionCubit>()
                    .addCarrier(sectionIndex, carriers[index]);
              },
            ),
          ),
        ),
      );
    },
  );
}
