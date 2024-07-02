import 'package:alati_app/tabs/maintenance_overview.dart';
import 'package:flutter/material.dart';

class ReadOnlyWrapper extends StatelessWidget {
  final Widget child;

  const ReadOnlyWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true, // Absorb any user interactions
      child: IgnorePointer(
        ignoring: false, // Ignore any pointer events
        child: child,
      ),
    );
  }
}

class CurrentStateScreen extends StatelessWidget {
  const CurrentStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // appBar: AppBar(
      //   title: const Text('Tab 1 (Read-Only)'),
      body: ReadOnlyWrapper(
        child: MaintenanceScreen(),
      ),
    );
  }
}
 