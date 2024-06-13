import 'dart:convert';

import 'package:alati_app/cubits/tool_fetcher_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class ToolsOverviewScreen extends StatefulWidget {
  const ToolsOverviewScreen({super.key});

  @override
  State<ToolsOverviewScreen> createState() => _ToolsOverviewScreenState();
}

class _ToolsOverviewScreenState extends State<ToolsOverviewScreen> {
  List<DatabaseEntry> databaseEntries = [];
  TextEditingController toolController = TextEditingController();
  TextEditingController projectController = TextEditingController();

  List<String> filterOptions = [
    'All Tools',
    'Tools Cleaned',
    'Tools Not Cleaned',
    'Tools Calibrated',
    'Tools Not Calibrated',
  ];
  String selectedFilter = 'All Tools';

  int numberOfSections = 22;
  List<String?> addedTools = List.generate(22, (index) => null); // Initialize with null
  final List<String> projectOptions = ['BMW Faar HI AU U06','BMW Faar KKST U11','BMW Faar Vorne ','BMW Faar HI MI  U06', 'Ineos Grenadier 1 Reihe','Empty'];
  final List<String> statusOptions = ['Active', 'Inactive', 'Pending'];
  final List<String> cleanStatusOptions = ['Clean', 'Not Clean'];
  final List<String> calibratedStatusOptions = ['Calibrated', 'Not Calibrated'];

  Timer? emailTimer;

  @override
  void initState() {
    super.initState();
    emailTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      checkToolAges();
    });
    context.read<ToolFetcherCubit>().fetchData('');

  }
  
  @override
  void dispose() {
    emailTimer?.cancel();
    super.dispose();
  }

  void checkToolAges() {
    final now = DateTime.now();
    for (var entry in databaseEntries) {
      if (now.difference(entry.dateAdded).inDays >= 3 && !entry.alertSent) {
        sendEmailAlert(entry.tool);
        setState(() {
          entry.alertSent = true;
        });
      }
    }
  }

  void sendEmailAlert(String toolName) async {
    final Email email = Email(
      body: 'The tool $toolName needs to be checked.',
      subject: 'Tool Check Alert',
      recipients: ['denis.akvic@jifeng-automotive.com'],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  void resetToolTimer(DatabaseEntry entry) {
    setState(() {
      entry.dateAdded = DateTime.now();
      entry.alertSent = false;
    });
  }

  List<DatabaseEntry> filterDatabaseEntries() {
    if (selectedFilter == 'All') {
      return databaseEntries;
    } else if (selectedFilter == 'Tools Cleaned') {
      return databaseEntries.where((entry) => entry.cleanStatus == 'Clean').toList();
    } else if (selectedFilter == 'Tools Not Cleaned') {
      return databaseEntries.where((entry) => entry.cleanStatus == 'Not Clean').toList();
    } else if (selectedFilter == 'Tools Calibrated') {
      return databaseEntries.where((entry) => entry.calibratedStatus == 'Calibrated').toList();
    } else if (selectedFilter == 'Tools Not Calibrated') {
      return databaseEntries.where((entry) => entry.calibratedStatus == 'Not Calibrated').toList();
    }
    return databaseEntries;
  }

    // Function to save data to shared preferences
  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> entries = databaseEntries.map((entry) => jsonEncode(entry.toMap())).toList();
    prefs.setStringList('entries', entries);
  }

  // Function to retrieve data from shared preferences
  Future<void> retrieveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? entries = prefs.getStringList('entries');
    if (entries != null) {
      setState(() {
        databaseEntries = entries.map((entry) => DatabaseEntry.fromMap(jsonDecode(entry))).toList();
      });
    }
  }
  
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blue[400],
      title: Text("Tool Overview"),
    ),
    body: BlocBuilder<ToolFetcherCubit, ToolFetcherState>(
      builder: (context, state) {
        if (state is ToolsFetcherSuccess) {
          final tools = state.tools;    // Map tools to database entries
          databaseEntries = tools.map((tool) {
            return DatabaseEntry(
              tool,
              projectOptions.first,
              'Active',
              'User',
              cleanStatusOptions.first,
              calibratedStatusOptions.first,
              DateTime.now(),
              DateTime.now(),
            );
          }).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: selectedFilter,
                  onChanged: (String? value) {
                    setState(() {
                      selectedFilter = value!;
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      DataTable(
                        columns: const <DataColumn>[
                          DataColumn(
                              label: Text('Tool',
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
                        rows: databaseEntries.map((entry) {
                          bool isOverdue = DateTime.now().difference(entry.dateAdded).inDays >= 3;
                          return DataRow(
                            color: isOverdue ? MaterialStateProperty.all(Colors.red.withOpacity(0.3)) : null,
                            cells: <DataCell>[
                              DataCell(Text(entry.tool)),
                              DataCell(buildProjectDropdown(entry)),
                              DataCell(buildStatusDropdown(entry)),
                              DataCell(Text(entry.userRole)),
                              DataCell(buildCleanStatusDropdown(entry)),
                              DataCell(buildCalibratedStatusDropdown(entry)),
                              DataCell(Text(entry.dateAdded.toString())),
                              DataCell(
                                  Text(calculateTimeElapsed(entry.dateAdded))),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        databaseEntries.remove(entry);
                                        setState(() {});
                                      },
                                    ),
                                    if (isOverdue)
                                      ElevatedButton(
                                        onPressed: () {
                                          resetToolTimer(entry);
                                        },
                                        child: const Text('Tool Check', style: TextStyle(color: Colors.red)),
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
                              controller: toolController,
                              decoration:
                                  const InputDecoration(labelText: 'Tool'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                DatabaseEntry newEntry = DatabaseEntry(
                                  toolController.text,
                                  projectController.text,
                                  'Active',
                                  'User',
                                  'Clean Status',
                                  'Calibrated Status',
                                  DateTime.now(),
                                  DateTime.now(),
                                );
                                databaseEntries.add(newEntry);
                                toolController.clear();
                                projectController.clear();
                                setState(() {});
                              },
                              child: const Text('Add Tool'),
                            ),
                            const SizedBox(height: 8),
                            //ElevatedButton(
                              //onPressed: () {
                                //databaseEntries[0].status = 'Inactive';
                                //databaseEntries[0].userRole = 'Admin';
                                //setState(() {});
                              //},
                              //child: const Text(
                                  //'Make a Change in Database (Key User)'),
                            //),
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

Widget buildProjectDropdown(DatabaseEntry entry) {
  String selectedProject = entry.project;
  if (!projectOptions.contains(selectedProject)) {
    selectedProject = projectOptions.first;
    entry.project = selectedProject;
    saveData(); // Save the updated value to SharedPreferences
  }

  return DropdownButton<String>(
    value: selectedProject,
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




  Widget buildStatusDropdown(DatabaseEntry entry) {
    return DropdownButton<String>(
      value: entry.status,
      onChanged: (newValue) {
        setState(() {
          entry.status = newValue!;
          //saveData(); // Save data after changing status
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

Widget buildCleanStatusDropdown(DatabaseEntry entry) {
  String selectedCleanStatus = entry.cleanStatus;
  if (!cleanStatusOptions.contains(selectedCleanStatus)) {
    selectedCleanStatus = cleanStatusOptions.first;
    entry.cleanStatus = selectedCleanStatus;
    saveData(); // Save the updated value to SharedPreferences
  }

  return DropdownButton<String>(
    value: selectedCleanStatus,
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


  Widget buildCalibratedStatusDropdown(DatabaseEntry entry) {
    // Check if the current calibratedStatus is present in calibratedStatusOptions
    if (!calibratedStatusOptions.contains(entry.calibratedStatus)) {
      // If not present, set the default value to the first item in calibratedStatusOptions
      entry.calibratedStatus = calibratedStatusOptions.first;
      //saveData(); // Save the updated value to the database
    }

    return DropdownButton<String>(
      value: entry.calibratedStatus,
      onChanged: (newValue) {
        setState(() {
          entry.calibratedStatus = newValue!;
          //saveData(); // Save data after changing calibrated status
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

class DatabaseEntry {
  String tool;
  String project;
  String status;
  String userRole;
  String cleanStatus;
  String calibratedStatus;
  DateTime dateAdded;
  DateTime dateCleaned;
  bool alertSent = false;


  DatabaseEntry(
    this.tool,
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
      'tool': tool,
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
  factory DatabaseEntry.fromMap(Map<String, dynamic> map) {
    return DatabaseEntry(
      map['tool'],
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
