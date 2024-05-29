import 'package:alati_app/cubits/tool_fetcher_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'dart:async';

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
    'All',
    'Tools Cleaned',
    'Tools Not Cleaned',
    'Tools Calibrated',
    'Tools Not Calibrated',
  ];
  String selectedFilter = 'All';

  int numberOfSections = 22;
  List<String?> addedTools =
      List.generate(22, (index) => null); // Initialize with null

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToolFetcherCubit, ToolFetcherState>(
      builder: (context, state) {
        if (state is ToolsFetcherSuccess) {
          final tools = state.tools;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
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
                      child: tools.isNotEmpty
                          ? ListView.builder(
                              itemCount: filterDatabaseEntries().length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title:
                                      Text(filterDatabaseEntries()[index].tool),
                                );
                              },
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: DataTable(
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
                        rows: filterDatabaseEntries().map((entry) {
                          bool isOverdue = DateTime.now().difference(entry.dateAdded).inDays >= 3;
                          return DataRow(
                            color: isOverdue ? MaterialStateProperty.all(Colors.red.withOpacity(0.3)) : null,
                            cells: <DataCell>[
                              DataCell(Text(entry.tool)),
                              DataCell(Text(entry.project)),
                              DataCell(Text(entry.status)),
                              DataCell(Text(entry.userRole)),
                              DataCell(Text(entry.cleanStatus)),
                              DataCell(Text(entry.calibratedStatus)),
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
                          TextField(
                            controller: projectController,
                            decoration:
                                const InputDecoration(labelText: 'Project'),
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
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
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
}