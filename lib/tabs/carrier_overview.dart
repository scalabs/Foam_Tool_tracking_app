import 'dart:convert';
import 'package:alati_app/cubits/carrier_fetcher_cubit.dart';
import 'package:alati_app/cubits/tool_fetcher_cubit.dart';
import 'package:alati_app/services/carrier_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';


class CarrierOverviewScreen extends StatefulWidget {
  const CarrierOverviewScreen({super.key});

  @override
  State<CarrierOverviewScreen> createState() => _CarrierOverviewScreenState();
}


class _CarrierOverviewScreenState extends State<CarrierOverviewScreen> {
  List<DatabaseCarrierEntry> databaseCarrierEntries = [];
  TextEditingController carrierController = TextEditingController();
  TextEditingController projectController = TextEditingController();

  List<String> filterOptions = [
    'All Carriers',
    'Carriers Cleaned',
    'Carriers Not Cleaned',
    'Carriers Calibrated',
    'Carriers Not Calibrated',
  ];
  String selectedFilter = 'All Carriers';

    int numberOfSections = 22;
  List<String?> addedCarrier =
      List.generate(22, (index) => null); // Initialize with null
  final List<String> projectOptions = [
    'BMW Faar HI AU U06',
    'BMW Faar KKST U11',
    'BMW Faar Vorne ',
    'BMW Faar HI MI  U06',
    'Ineos Grenadier 1 Reihe',
    'Empty'
  ];
  final List<String> statusOptions = ['Active', 'Inactive', 'Pending', 'Active working condition', 'Inactive not working condition'];
  final List<String> cleanStatusOptions = ['Clean', 'Not Clean'];
  final List<String> calibratedStatusOptions = ['Calibrated', 'Not Calibrated'];


  @override
  void initState() {
    super.initState();

    context.read<CarrierFetcherCubit>().fetchData('');
    retrieveData(); // Retrieve data on initialization
  }


  @override
  void dispose() {

    super.dispose();
  }






  List<DatabaseCarrierEntry> filterDatabaseEntries() {
    if (selectedFilter == 'All Carriers') {
      return databaseCarrierEntries;
    } else if (selectedFilter == 'Carriers Cleaned') {
      return databaseCarrierEntries
          .where((entry) => entry.cleanStatus == 'Clean')
          .toList();
    } else if (selectedFilter == 'Carriers Not Cleaned') {
      return databaseCarrierEntries
          .where((entry) => entry.cleanStatus == 'Not Clean')
          .toList();
    } else if (selectedFilter == 'Carriers Calibrated') {
      return databaseCarrierEntries
          .where((entry) => entry.calibratedStatus == 'Calibrated')
          .toList();
    } else if (selectedFilter == 'Carriers Not Calibrated') {
      return databaseCarrierEntries
          .where((entry) => entry.calibratedStatus == 'Not Calibrated')
          .toList();
    }
    return databaseCarrierEntries;
  }


  // Function to save data to shared preferences
  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> entries =
        databaseCarrierEntries.map((entry) => jsonEncode(entry.toMap())).toList();
    prefs.setStringList('entries', entries);
  }

  // Function to retrieve data from shared preferences
  Future<void> retrieveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? entries = prefs.getStringList('entries');
    if (entries != null) {
      setState(() {
        databaseCarrierEntries = entries
            .map((entry) => DatabaseCarrierEntry.fromMap(jsonDecode(entry)))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: const Text("Carriers Overview"),
      ),
      body: BlocBuilder<CarrierFetcherCubit, FetcherState>(
        builder: (context, state) {
          if (state is FetcherSuccess) {
            final carrier = state.items;

            // Only update databaseEntries if it is empty to avoid overwriting existing data
            if (databaseCarrierEntries.isEmpty) {
              databaseCarrierEntries = carrier.map((carrier) {
                return DatabaseCarrierEntry(
                  carrier,
                  projectOptions.first,
                  'Active',
                  'User',
                  cleanStatusOptions.first,
                  calibratedStatusOptions.first,
                  DateTime.now(),
                  DateTime.now(),
                );
              }).toList();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    onChanged: (String? value) {
                      setState(() {
                        selectedFilter = value!;
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        DataTable(
                          columns: const <DataColumn>[
                            DataColumn(
                                label: Text('Carrier',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Project',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Status',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('User Role',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Clean Status',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Calibrated Status',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Date Added',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Time Elapsed',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Actions',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold))),
                          ],
                          rows: databaseCarrierEntries.map((entry) {
                            bool isOverdue = DateTime.now()
                                    .difference(entry.dateAdded)
                                    .inDays >=
                                3;
                            return DataRow(
                              color: isOverdue
                                  ? WidgetStateProperty.all(
                                      Colors.red.withOpacity(0.3))
                                  : null,
                              cells: <DataCell>[
                                DataCell(Text(entry.carrier)),
                                DataCell(buildProjectDropdown(entry)),
                                DataCell(buildStatusDropdown(entry)),
                                DataCell(Text(entry.userRole)),
                                DataCell(buildCleanStatusDropdown(entry)),
                                DataCell(buildCalibratedStatusDropdown(entry)),
                                DataCell(Text(entry.dateAdded.toString())),
                                DataCell(Text(
                                    calculateTimeElapsed(entry.dateAdded))),
                                DataCell(
                                  Row(
                                    children: [
                                       IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                          try {
                                            await context.read<APICarriersService>().deleteData(entry.carrier, selectedFilter);
                                            setState(() {
                                              databaseCarrierEntries.remove(entry);
                                            });
                                            saveData(); // Save data after deleting entry
                                          } catch (e) {
                                            debugPrint('Error deleting carrier: $e');
                                          }
                                        },
                                      ),                                     
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: carrierController,
                                decoration:
                                    const InputDecoration(labelText: 'Carrier'),
                              ),
                              ElevatedButton(
                              onPressed: () async {
                                String carrierName = carrierController.text;
                                String project = projectOptions.isNotEmpty ? projectOptions.first : '';
                                String status = statusOptions.isNotEmpty ? statusOptions.first : '';
                                String cleanStatus = cleanStatusOptions.isNotEmpty ? cleanStatusOptions.first : '';
                                String calibratedStatus = calibratedStatusOptions.isNotEmpty ? calibratedStatusOptions.first : '';

                                if (carrierName.isNotEmpty) {
                                  try {
                                    // Call your API service method to add carrier
                                    await context.read<APICarriersService>().addData(carrierName, project);

                                    // Create a new database entry
                                    DatabaseCarrierEntry newEntry = DatabaseCarrierEntry(
                                      carrierName,
                                      project,
                                      status,
                                      'User',
                                      cleanStatus,
                                      calibratedStatus,
                                      DateTime.now(),
                                      DateTime.now(),
                                    );

                                    // Update state with the new entry and clear text input
                                    setState(() {
                                      databaseCarrierEntries.add(newEntry);
                                      carrierController.clear();
                                    });

                                    // Save data (if needed)
                                    saveData(); // Example saveData function

                                  } catch (e) {
                                    debugPrint('Error adding carrier: $e');
                                  }
                                }
                              },
                              child: const Text('Add Carrier'),
                            ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget buildProjectDropdown(DatabaseCarrierEntry entry) {
    return DropdownButton<String>(
      value: entry.project,
      onChanged: (newValue) {
        setState(() {
          entry.project = newValue!;
          saveData(); // Save data after changing project
        });
      },
      items: projectOptions.map((project) {
        return DropdownMenuItem<String>(
          value: project,
          child: Text(project),
        );
      }).toList(),
    );
  }

  Widget buildStatusDropdown(DatabaseCarrierEntry entry) {
    return DropdownButton<String>(
      value: entry.status,
      onChanged: (newValue) {
        setState(() {
          entry.status = newValue!;
          saveData(); // Save data after changing status
        });
      },
      items: statusOptions.map((status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(status),
        );
      }).toList(),
    );
  }

  Widget buildCleanStatusDropdown(DatabaseCarrierEntry entry) {
    return DropdownButton<String>(
      value: entry.cleanStatus,
      onChanged: (newValue) {
        setState(() {
          entry.cleanStatus = newValue!;
          saveData(); // Save data after changing clean status
        });
      },
      items: cleanStatusOptions.map((status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(status),
        );
      }).toList(),
    );
  }

  Widget buildCalibratedStatusDropdown(DatabaseCarrierEntry entry) {
    return DropdownButton<String>(
      value: entry.calibratedStatus,
      onChanged: (newValue) {
        setState(() {
          entry.calibratedStatus = newValue!;
          saveData(); // Save data after changing calibrated status
        });
      },
      items: calibratedStatusOptions.map((status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(status),
        );
      }).toList(),
    );
  }

  String calculateTimeElapsed(DateTime dateAdded) {
    Duration difference = DateTime.now().difference(dateAdded);
    return '${difference.inDays} days, ${difference.inHours.remainder(24)} hours';
  }
}

class DatabaseCarrierEntry {
  String carrier;
  String project;
  String status;
  String userRole;
  String cleanStatus;
  String calibratedStatus;
  DateTime dateAdded;
  DateTime dateCleaned;
  bool alertSent = false;

  DatabaseCarrierEntry(
    this.carrier,
    this.project,
    this.status,
    this.userRole,
    this.cleanStatus,
    this.calibratedStatus,
    this.dateAdded,
    this.dateCleaned,
  );

  Map<String, dynamic> toMap() {
    return {
      'carrier': carrier,
      'project': project, // Changed from project to projectStatus
      'status': status,
      'userRole': userRole,
      'cleanStatus': cleanStatus,
      'calibratedStatus': calibratedStatus,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
      'dateCleaned': dateCleaned.millisecondsSinceEpoch,
    };
  }

  // Method to create DatabaseEntry from Map
  factory DatabaseCarrierEntry.fromMap(Map<String, dynamic> map) {
    return DatabaseCarrierEntry(
      map['carrier'],
      map['project'], // Changed from project to projectStatus
      map['status'],
      map['userRole'],
      map['cleanStatus'],
      map['calibratedStatus'],
      DateTime.fromMillisecondsSinceEpoch(map['dateAdded']),
      DateTime.fromMillisecondsSinceEpoch(map['dateCleaned']),
    );
  }
}