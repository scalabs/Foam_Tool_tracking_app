// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   List<Map<String, dynamic>> items = [];
//   final TextEditingController _controller = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }

//   Future<void> fetchData() async {
//     final response = await http.get('http://your_python_api_address/api/items');
//     if (response.statusCode == 200) {
//       setState(() {
//         items = List<Map<String, dynamic>>.from(json.decode(response.body));
//       });
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }

//   Future<void> addItem(String name) async {
//     await http.post(
//       'http://your_python_api_address/api/items',
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'name': name}),
//     );
//     fetchData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flutter Database Example'),
//       ),
//       body: Column(
//         children: [
//           TextField(
//             controller: _controller,
//             decoration: InputDecoration(labelText: 'Item name'),
//           ),
//           ElevatedButton(
//             onPressed: () => addItem(_controller.text),
//             child: Text('Add Item'),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: items.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(items[index]['name']),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
