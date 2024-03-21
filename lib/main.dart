import 'package:alati_app/cubits/current_state_cubit.dart';
import 'package:alati_app/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
// import '/cubits/maintenance_cubit.dart';
// import '/cubits/current_state_cubit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DashboardScreen(),
    );
  }
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MultiBlocProvider(
//         providers: [
//           BlocProvider<MaintenanceCubit>(
//             create: (BuildContext context) => MaintenanceCubit(),
              //  create : (BuildContext context) => CurrentStateCubit(),
//           ),
//           // Other BlocProviders if any
//         ],
//         child: Scaffold(
//           body: Tab4(), Tab1() // Ensure Tab4 is a child of MultiBlocProvider
             
//         ),
//       ),
//     );
//   }
// }