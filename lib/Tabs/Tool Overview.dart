// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class Tab3 extends StatefulWidget {
//   @override
//   _Tab3State createState() => _Tab3State();
// }

// class _Tab3State extends State<Tab3> {
//   List<DatabaseEntry> databaseEntries = [];
//   TextEditingController toolController = TextEditingController();
//   TextEditingController projectController = TextEditingController();

//   List<String> filterOptions = [
//     'All',
//     'Tools Cleaned',
//     'Tools Not Cleaned',
//     'Tools Calibrated',
//     'Tools Not Calibrated',
//   ];
//   String selectedFilter = 'All';

//   List<String> tools = [];
//   int numberOfSections = 22;
//   List<String?> addedTools =
//       List.generate(22, (index) => null); // Initialize with null

//   final List<String> statusOptions = ['Active', 'Inactive', 'Pending'];
//   final List<String> cleanStatusOptions = ['Clean', 'Not Clean'];
//   final List<String> calibratedStatusOptions = ['Calibrated', 'Not Calibrated'];

//   @override
//   void initState() {
//     fetchData();
//     super.initState();
//   }

//   Future<void> fetchData() async {
//     final response = await http.get(
//       Uri.parse('http://10.3.41.36:7000/api/active'),
//       headers: {'Content-Type': 'application/json'},
//     );

//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       setState(() {
//         tools = List<String>.from(data.map((item) => item['Alat']));
//         updateDatabaseEntries();
//       });
//     } else {
//       print('Failed to load data');
//     }
//   }

//   void updateDatabaseEntries() {
//     // Clear existing databaseEntries and create new ones from API tools
//     databaseEntries.clear();
//     for (String tool in tools) {
//       // You can customize other fields as per your requirements
//       databaseEntries.add(
//         DatabaseEntry(
//           tool,
//           'Project X',
//           'Active',
//           'Key User',
//           'Clean Status',
//           'Calibrated Status',
//           DateTime.now(),
//           DateTime.now().subtract(Duration(days: 1)),
//         ),
//       );
//     }
//   }

//   List<DatabaseEntry> filterDatabaseEntries() {
//     if (selectedFilter == 'All') {
//       return databaseEntries;
//     } else if (selectedFilter == 'Tools Cleaned') {
//       return databaseEntries.where((entry) => entry.cleanStatus == 'Clean').toList();
//     } else if (selectedFilter == 'Tools Not Cleaned') {
//       return databaseEntries.where((entry) => entry.cleanStatus == 'Not Clean').toList();
//     } else if (selectedFilter == 'Tools Calibrated') {
//       return databaseEntries.where((entry) => entry.calibratedStatus == 'Calibrated').toList();
//     } else if (selectedFilter == 'Tools Not Calibrated') {
//       return databaseEntries.where((entry) => entry.calibratedStatus == 'Not Calibrated').toList();
//     }
//     return [];
//   }

// @override
// Widget build(BuildContext context) {
//   return Row(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: <Widget>[
//       Container(
//         width: 250,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: EdgeInsets.all(8.0),
//               child: DropdownButton<String>(
//                 value: selectedFilter,
//                 onChanged: (String? value) {
//                   setState(() {
//                     selectedFilter = value!;
//                   });
//                 },
//                 items: filterOptions.map<DropdownMenuItem<String>>((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//               ),
//             ),
//             Expanded(
//               child: tools.isNotEmpty
//                   ? ListView.builder(
//                       itemCount: filterDatabaseEntries().length,
//                       itemBuilder: (context, index) {
//                         return ListTile(
//                           title: Text(filterDatabaseEntries()[index].tool),
//                         );
//                       },
//                     )
//                   : Center(
//                       child: CircularProgressIndicator(),
//                     ),
//             ),
//           ],
//         ),
//       ),
//       VerticalDivider(),
//       Expanded(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             Expanded(
//               child: DataTable(
//                 columns: <DataColumn>[
//                   DataColumn(label: Text('Tool', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('Project', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('User Role', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('Clean Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('Calibrated Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('Date Added', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('Time Elapsed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                 ],
//                 rows: filterDatabaseEntries().map((entry) {
//                   return DataRow(
//                     cells: <DataCell>[
//                       DataCell(Text(entry.tool)),
//                       DataCell(Text(entry.project)),
//                       DataCell(Text(entry.status)),
//                       DataCell(Text(entry.userRole)),
//                       DataCell(Text(entry.cleanStatus)),
//                       DataCell(Text(entry.calibratedStatus)),
//                       DataCell(Text(entry.dateAdded.toString())),
//                       DataCell(Text(calculateTimeElapsed(entry.dateAdded))),
//                       DataCell(
//                         IconButton(
//                           icon: Icon(Icons.delete),
//                           onPressed: () {
//                             databaseEntries.remove(entry);
//                             setState(() {});
//                           },
//                         ),
//                       ),
//                     ],
//                   );
//                 }).toList(),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: toolController,
//                     decoration: InputDecoration(labelText: 'Tool'),
//                   ),
//                   TextField(
//                     controller: projectController,
//                     decoration: InputDecoration(labelText: 'Project'),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       DatabaseEntry newEntry = DatabaseEntry(
//                         toolController.text,
//                         projectController.text,
//                         'Active',
//                         'User',
//                         'Clean Status',
//                         'Calibrated Status',
//                         DateTime.now(),
//                         DateTime.now(),
//                       );
//                       databaseEntries.add(newEntry);
//                       toolController.clear();
//                       projectController.clear();
//                       setState(() {});
//                     },
//                     child: Text('Add Tool'),
//                   ),
//                   SizedBox(height: 8),
//                   ElevatedButton(
//                     onPressed: () {
//                       databaseEntries[0].status = 'Inactive';
//                       databaseEntries[0].userRole = 'Admin';
//                       setState(() {});
//                     },
//                     child: Text('Make a Change in Database (Key User)'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     ],
//   );
// }

//   String calculateTimeElapsed(DateTime dateAdded) {
//     Duration difference = DateTime.now().difference(dateAdded);
//     return '${difference.inDays} days, ${difference.inHours.remainder(24)} hours';
//   }
// }

// class DatabaseEntry {
//   String tool;
//   String project;
//   String status;
//   String userRole;
//   String cleanStatus;
//   String calibratedStatus;
//   DateTime dateAdded;
//   DateTime dateCleaned;

//   DatabaseEntry(
//     this.tool,
//     this.project,
//     this.status,
//     this.userRole,
//     this.cleanStatus,
//     this.calibratedStatus,
//     this.dateAdded,
//     this.dateCleaned,
//   );
// } 

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Tab3 extends StatefulWidget {
  @override
  _Tab3State createState() => _Tab3State();
}

class _Tab3State extends State<Tab3> {
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

  List<String> tools = [];
  final List<String> statusOptions = ['Active', 'Inactive', 'Pending'];
  final List<String> cleanStatusOptions = ['Clean', 'Not Clean'];
  final List<String> calibratedStatusOptions = ['Calibrated', 'Not Calibrated'];

  @override
  void initState() {
    retrieveData(); // Retrieve data from shared preferences
    super.initState();
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('http://10.3.41.36:7000/api/active'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        tools = List<String>.from(data.map((item) => item['Alat']));
        databaseEntries.clear();
        for (String tool in tools) {
          databaseEntries.add(
            DatabaseEntry(
              tool,
              'Project X',
              'Active',
              'Key User',
              cleanStatusOptions.first,
              calibratedStatusOptions.first,
              DateTime.now(),
              DateTime.now().subtract(Duration(days: 1)),
            ),
          );
        }
        saveData(); // Save fetched data
      });
    } else {
      print('Failed to load data');
    }
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
      body: Column(
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
                  fetchData(); // Fetch data again when filter changes
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
                    columns: <DataColumn>[
                      DataColumn(label: Text('Tool', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Project', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('User Role', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Clean Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Calibrated Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Date Added', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Time Elapsed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                    ],
                    rows: databaseEntries.map((entry) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(entry.tool)),
                          DataCell(Text(entry.project)),
                          DataCell(buildStatusDropdown(entry)),
                          DataCell(Text(entry.userRole)),
                          DataCell(buildCleanStatusDropdown(entry)),
                          DataCell(buildCalibratedStatusDropdown(entry)),
                          DataCell(Text(entry.dateAdded.toString())),
                          DataCell(Text(calculateTimeElapsed(entry.dateAdded))),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  databaseEntries.remove(entry);
                                  saveData(); // Save data after deletion
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: toolController,
                  decoration: InputDecoration(labelText: 'Tool'),
                ),
                TextField(
                  controller: projectController,
                  decoration: InputDecoration(labelText: 'Project'),
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

                    setState(() {
                      databaseEntries.add(newEntry);
                      saveData(); // Save data after adding a new entry
                      toolController.clear();
                      projectController.clear();
                    });
                  },
                  child: Text('Add Tool'),
                ),
                SizedBox(height: 8), // Add padding between buttons
                ElevatedButton(
                  onPressed: () {
                    // Simulate making a change in the database (placeholder)
                    setState(() {
                      databaseEntries[0].status = 'Inactive';
                      databaseEntries[0].userRole = 'Admin';
                      saveData(); // Save data after making a change
                    });
                  },
                  child: Text('Make a Change in Database (Key User)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusDropdown(DatabaseEntry entry) {
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

  Widget buildCleanStatusDropdown(DatabaseEntry entry) {
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

  Widget buildCalibratedStatusDropdown(DatabaseEntry entry) {
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

// DatabaseEntry class with methods to convert to/from Map for shared preferences
class DatabaseEntry {
  String tool;
  String project;
  String status;
  String userRole;
  String cleanStatus;
  String calibratedStatus;
  DateTime dateAdded;
  DateTime dateCleaned;

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

  // Method to convert DatabaseEntry to Map
  Map<String, dynamic> toMap() {
    return {
      'tool': tool,
      'project': project,
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
      map['project'],
      map['status'],
      map['userRole'],
      map['cleanStatus'],
      map['calibratedStatus'],
      DateTime.fromMillisecondsSinceEpoch(map['dateAdded']),
      DateTime.fromMillisecondsSinceEpoch(map['dateCleaned']),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Tab3(),
  ));
}
