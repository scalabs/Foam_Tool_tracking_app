import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Tab4 extends StatefulWidget {
  const Tab4({super.key});

  @override
  State<Tab4> createState() => _Tab4State();
}

class _Tab4State extends State<Tab4> {
  List<String> filterOptions = [
    'All',
    'Tools Cleaned',
    'Tools Not Cleaned',
    'Tools Calibrated',
    'Tools Not Calibrated',
  ];
  String selectedFilter = 'All';

  List<String> tools = [];
  int numberOfSections = 22;
  List<String?> addedTools =
      List.generate(22, (index) => null); // Initialize with null
  final _controller = TextEditingController();
  late SharedPreferences prefs;

  @override
  void initState() {
    fetchData();
    _loadSavedTableName();
    super.initState();
  }

  Future<void> fetchData() async {
    String filterEndpoint = '';
    switch (selectedFilter) {
      case 'Tools Cleaned':
        filterEndpoint = 'cleaned';
        break;
      case 'Tools Not Cleaned':
        filterEndpoint = 'not_cleaned';
        break;
      case 'Tools Calibrated':
        filterEndpoint = 'calibrated';
        break;
      case 'Tools Not Calibrated':
        filterEndpoint = 'not_calibrated';
        break;
      default:
        // Fetch all tools if no filter is selected
        break;
    }

    String apiUrl = filterEndpoint.isNotEmpty
        ? 'http://127.0.0.1:5000/api/$filterEndpoint'
        : 'http://127.0.0.1:5000/api/active';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        tools = List<String>.from(data.map((item) => item['Alat']));
      });
    } else {
      debugPrint('Failed to load data');
    }
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
                  fetchData(); // Fetch data again when filter changes
                });
              },
              items:
                  filterOptions.map<DropdownMenuItem<String>>((String value) {
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
          child: tools.isNotEmpty
              ? ListView.builder(
                  itemCount: tools.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(tools[index]),
                      onTap: () {
                        showAddToolDialog(index);
                      },
                    );
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
        const VerticalDivider(),
        Expanded(
          child: Stack(
            children: [
              Center(
                child: Text(
                  _controller.text,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Center(
                child: SizedBox(
                  width: 900,
                  height: 900,
                  child: DragTarget<String>(
                    builder: (context, candidateData, rejectedData) {
                      return PieChart(
                        PieChartData(
                          sections: List.generate(
                            numberOfSections,
                            (index) => index,
                          ).map(
                            (e) {
                              var tool = addedTools[e];
                              return PieChartSectionData(
                                color: Colors.blue[300],
                                value: 1,
                                title: tool ?? (e + 1).toString(),
                                radius: 400,
                                titlePositionPercentageOffset: 0.6,
                                badgeWidget: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        showAddToolDialog(e);
                                      });
                                    },
                                    icon: tool == null
                                        ? const Icon(
                                            Icons.add_circle_outline_outlined)
                                        : const Icon(Icons
                                            .remove_circle_outline_outlined),
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
              ),
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
                        value: (numberOfSections / 30),
                        onChanged: (v) {
                          setState(() {
                            numberOfSections = (v * 30).toInt().clamp(1, 30);
                          });
                        },
                      ),
                      Text(
                        'Number of sections: $numberOfSections',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void showAddToolDialog(int sectionIndex) {
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
                  registerTool(sectionIndex, tools[index]);
                },
              ),
              itemCount: tools.length,
            ),
          ),
        );
      },
    );
  }

  void registerTool(int sectionIndex, String tool) {
    setState(() {
      addedTools[sectionIndex] = tool;
    });
  }

  void removeItem(String item) {
    setState(() {
      filterOptions.remove(item);
    });
  }
}
