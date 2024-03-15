import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Tab3 extends StatefulWidget {
  const Tab3({super.key});

  @override
  State<Tab3> createState() => _Tab3State();
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
  int numberOfSections = 22;
  List<String?> addedTools =
      List.generate(22, (index) => null); // Initialize with null

  final List<String> statusOptions = ['Active', 'Inactive', 'Pending'];
  final List<String> cleanStatusOptions = ['Clean', 'Not Clean'];
  final List<String> calibratedStatusOptions = ['Calibrated', 'Not Calibrated'];

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/api/active'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        tools = List<String>.from(data.map((item) => item['Alat']));
        updateDatabaseEntries();
      });
    } else {
      debugPrint('Failed to load data');
    }
  }

  void updateDatabaseEntries() {
    // Clear existing databaseEntries and create new ones from API tools
    databaseEntries.clear();
    for (String tool in tools) {
      // You can customize other fields as per your requirements
      databaseEntries.add(
        DatabaseEntry(
          tool,
          'Project X',
          'Active',
          'Key User',
          'Clean Status',
          'Calibrated Status',
          DateTime.now(),
          DateTime.now().subtract(const Duration(days: 1)),
        ),
      );
    }
  }

  List<DatabaseEntry> filterDatabaseEntries() {
    if (selectedFilter == 'All') {
      return databaseEntries;
    } else if (selectedFilter == 'Tools Cleaned') {
      return databaseEntries
          .where((entry) => entry.cleanStatus == 'Clean')
          .toList();
    } else if (selectedFilter == 'Tools Not Cleaned') {
      return databaseEntries
          .where((entry) => entry.cleanStatus == 'Not Clean')
          .toList();
    } else if (selectedFilter == 'Tools Calibrated') {
      return databaseEntries
          .where((entry) => entry.calibratedStatus == 'Calibrated')
          .toList();
    } else if (selectedFilter == 'Tools Not Calibrated') {
      return databaseEntries
          .where((entry) => entry.calibratedStatus == 'Not Calibrated')
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
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
                            title: Text(filterDatabaseEntries()[index].tool),
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
                                fontSize: 16, fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Project',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Status',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('User Role',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Clean Status',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Calibrated Status',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Date Added',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Time Elapsed',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Actions',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                  ],
                  rows: filterDatabaseEntries().map((entry) {
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(entry.tool)),
                        DataCell(Text(entry.project)),
                        DataCell(Text(entry.status)),
                        DataCell(Text(entry.userRole)),
                        DataCell(Text(entry.cleanStatus)),
                        DataCell(Text(entry.calibratedStatus)),
                        DataCell(Text(entry.dateAdded.toString())),
                        DataCell(Text(calculateTimeElapsed(entry.dateAdded))),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              databaseEntries.remove(entry);
                              setState(() {});
                            },
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
                      decoration: const InputDecoration(labelText: 'Tool'),
                    ),
                    TextField(
                      controller: projectController,
                      decoration: const InputDecoration(labelText: 'Project'),
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
                    ElevatedButton(
                      onPressed: () {
                        databaseEntries[0].status = 'Inactive';
                        databaseEntries[0].userRole = 'Admin';
                        setState(() {});
                      },
                      child: const Text('Make a Change in Database (Key User)'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;


// class Tab3 extends StatefulWidget {
//   @override
//   _Tab3State createState() => _Tab3State();
// }

// class _Tab3State extends State<Tab3> {
//   // // Placeholder data for the table representing a database
//   // List<DatabaseEntry> databaseEntries = [
//   //   DatabaseEntry('Tool A', 'Project X', 'Active', 'Key User', DateTime.now(),
//   //       DateTime.now().subtract(Duration(days: 1))),
//   //   DatabaseEntry('Tool B', 'Project Y', 'Inactive', 'Viewer', DateTime.now(),
//   //       DateTime.now().subtract(Duration(days: 3))),
//   //   DatabaseEntry('Tool C', 'Project Z', 'Active', 'Viewer', DateTime.now(),
//   //       DateTime.now().subtract(Duration(days: 5))),
//   //   // Add more database entries
//   // ];
//   List<DatabaseEntry> databaseEntries = [];
//   TextEditingController toolController = TextEditingController();
//   TextEditingController projectController = TextEditingController();

//   final List<String> lotrItems = [
//     'Tools Cleaned',
//     'Tools Not Cleaned',
//     'Tools Replaced',
//     'Tools Old',
//     'Tools Checked',
//     'Tools Calibrated',
//     'Tools In Maintenance',
//     'Tools In Use',
//     'Tools Idle',
//     'Tools Under Repair',
//   ];
//   String selectedItem = '';
//   List<String> tools = [];
//   int numberOfSections = 22;
//   List<String?> addedTools =
//       List.generate(22, (index) => null); // Initialize with null
//   final List<String> statusOptions = ['Active', 'Inactive', 'Pending']; //za dropdown za mijenjanje statusa
//   final List<String> cleanStatusOptions = ['Clean', 'Not Clean']; //za dropdown za mijenjanje statusa
//   final List<String> calibratedStatusOptions = ['Calibrated', 'Not Calibrated']; //za dropdown za mijenjanje statusa

//   @override
//   void initState() {
//     fetchData();
//     selectedItem = lotrItems.first;
//     super.initState();
//   }

//   Future<void> fetchData() async {
//     final response = await http.get(
//       Uri.parse('http://127.0.0.1:5000/api/active'),
//       headers: {'Content-Type': 'application/json'},
//     );

//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       setState(() {
//         tools = List<String>.from(data.map((item) => item['Alat']));
        
//         // Clear existing databaseEntries and create new ones from API tools
//         databaseEntries.clear();
//         for (String tool in tools) {
//           // You can customize other fields as per your requirements
//           databaseEntries.add(
//               DatabaseEntry(
//               tool,
//               'Project X',
//               'Active',
//               'Key User',
//               cleanStatusOptions.first, // Initialize with the first option
//               calibratedStatusOptions.first, // Initialize with the first option
//               DateTime.now(),
//               DateTime.now().subtract(Duration(days: 1)),
//             ),
//           );
//         }
//       });
//     } else {
//       print('Failed to load data');
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: <Widget>[
//         Container(
//           width: 250,
//           child: ListView.builder(
//             itemCount: lotrItems.length,
//             itemBuilder: (context, index) {
//               return CheckboxListTile(
//                 value: selectedItem == lotrItems[index],
//                 onChanged: (v) {
//                   setState(() {
//                     selectedItem = lotrItems[index];
//                   });
//                 },
//                 title: Text(lotrItems[index]),
//               );
//             },
//           ),
//         ),
//         VerticalDivider(),
//         Container(
//           width: 250,
//           child: tools.isNotEmpty
//               ? ListView.builder(
//                   itemCount: tools.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       title: Text(tools[index]),
//                     );
//                   },
//                 )
//               : Center(
//                   child: CircularProgressIndicator(),
//                 ),
//         ),
//         VerticalDivider(),
//         // Display the table representing the database
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               // Data table
//               Expanded(
//                 child: DataTable(
//                   columns: <DataColumn>[
//                     DataColumn(label: Text('Tool', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                     DataColumn(label: Text('Project', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                     DataColumn(label: Text('Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                     DataColumn(label: Text('User Role', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                     DataColumn(label: Text('Clean Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))), // Added Clean Status
//                     DataColumn(label: Text('Calibrated Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))), // Added Calibrated Status
//                     DataColumn(label: Text('Date Added', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                     DataColumn(label: Text('Time Elapsed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                     DataColumn(label: Text('Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//                   ],
//               rows: databaseEntries.map((entry) {
//                 return DataRow(
//                   cells: <DataCell>[
//                     DataCell(Text(entry.tool)),
//                     DataCell(Text(entry.project)),
//                     DataCell(buildStatusDropdown(entry)),
//                     DataCell(Text(entry.userRole)),
//                     DataCell(buildCleanStatusDropdown(entry)),
//                     DataCell(buildCalibratedStatusDropdown(entry)),
//                     DataCell(Text(entry.dateAdded.toString())),
//                     DataCell(Text(calculateTimeElapsed(entry.dateAdded))),
//                     DataCell(
//                       IconButton(
//                         icon: Icon(Icons.delete),
//                         onPressed: () {
//                               databaseEntries.remove(entry);
//                               setState(() {});
//                             },
//                           ),
//                         ),
//                       ],
//                     );
//                   }).toList(),
//                 ),
//               ),

//               // Form for adding a new tool
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     TextField(
//                       controller: toolController,
//                       decoration: InputDecoration(labelText: 'Tool'),
//                     ),
//                     TextField(
//                       controller: projectController,
//                       decoration: InputDecoration(labelText: 'Project'),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         // Add a new tool to the database (placeholder)
//                         DatabaseEntry newEntry = DatabaseEntry(
//                           toolController.text,
//                           projectController.text,
//                           'Active',
//                           'User',
//                           'Clean Status',
//                           'Calibrated Status', // Placeholder for calibrated status
//                           DateTime.now(),
//                           DateTime.now(),
//                         );
//                         databaseEntries.add(newEntry);
//                         toolController.clear();
//                         projectController.clear();
//                         setState(() {});
//                       },
//                       child: Text('Add Tool'),
//                     ),
//                     SizedBox(height: 8), // Add padding between buttons
//                     ElevatedButton(
//                     onPressed: () {
//                     // Simulate making a change in the database (placeholder)
//                     databaseEntries[0].status = 'Inactive';
//                     databaseEntries[0].userRole = 'Admin';
//                     setState(() {});
//                   },
//                   child: Text('Make a Change in Database (Key User)'),
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

//   Widget buildStatusDropdown(DatabaseEntry entry) {
//     return DropdownButton<String>(
//       value: entry.status,
//       onChanged: (newValue) {
//         setState(() {
//           entry.status = newValue!;
//         });
//       },
//       items: statusOptions.map((status) {
//         return DropdownMenuItem<String>(
//           value: status,
//           child: Text(status),
//         );
//       }).toList(),
//     );
//   }

//   Widget buildCleanStatusDropdown(DatabaseEntry entry) {
//     return DropdownButton<String>(
//       value: entry.cleanStatus,
//       onChanged: (newValue) {
//         setState(() {
//           entry.cleanStatus = newValue!;
//         });
//       },
//       items: cleanStatusOptions.map((status) {
//         return DropdownMenuItem<String>(
//           value: status,
//           child: Text(status),
//         );
//       }).toList(),
//     );
//   }

//   Widget buildCalibratedStatusDropdown(DatabaseEntry entry) {
//     return DropdownButton<String>(
//       value: entry.calibratedStatus,
//       onChanged: (newValue) {
//         setState(() {
//           entry.calibratedStatus = newValue!;
//         });
//       },
//       items: calibratedStatusOptions.map((status) {
//         return DropdownMenuItem<String>(
//           value: status,
//           child: Text(status),
//         );
//       }).toList(),
//     );
//   }
//   String calculateTimeElapsed(DateTime dateAdded) {
//     Duration difference = DateTime.now().difference(dateAdded);
//     return '${difference.inDays} days, ${difference.inHours.remainder(24)} hours';
//   }
// }
// // Ovdje se mora dodati sta smo dodali  na linijima 157 i 172 npr cleanStatus
// class DatabaseEntry {
//   String tool;
//   String project;
//   String status;
//   String userRole;
//   String cleanStatus;
//   String calibratedStatus;
//   DateTime dateAdded;
//   DateTime dateCleaned;
// // Ovdje se mora dodati sta smo dodali  na linijima 242 npr cleanStatus

//   DatabaseEntry(  this.tool,
//   this.project,
//   this.status,
//   this.userRole,
//   this.cleanStatus,
//   this.calibratedStatus,
//   this.dateAdded,
//   this.dateCleaned,);
// }


// ovu cemo listu mozda nekad u buducnosti koristiti
  // final List<String> toolsList = [
  //   'Foam dispenser nozzle',
  //   'Mixing chamber',
  //   'Foam flow regulator',
  //   'Control panel',
  //   'Foam density adjuster',
  //   'Temperature control unit',
  //   'Pressure gauge',
  //   'Safety interlock system',
  //   'Hose and nozzle assembly',
  //   'Foam material reservoir',
  //   'Proximity sensors',
  //   'Foam quality analyzer',
  //   'Programmable controller',
  //   'Emergency shut-off switch',
  //   'Flow rate meter',
  //   'Pneumatic connections',
  //   'Foam system diagnostics tool',
  //   'Filtration unit',
  //   'Foam chemical supply containers',
  //   'Operator\'s manual',
  // ];