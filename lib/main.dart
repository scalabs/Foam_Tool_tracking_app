import 'package:alati_app/dashboard/dashboard.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(FoamToolsApp());
}

class FoamToolsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DashboardScreen(),
    );
  }
}
