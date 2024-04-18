import 'package:alati_app/Tabs/Maintenace.dart';
import 'package:flutter/material.dart';

class ReadOnlyWrapper extends StatelessWidget {
  final Widget child;

  const ReadOnlyWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true, // Absorb any user interactions
      child: IgnorePointer(
        ignoring: true, // Ignore any pointer events
        child: child,
      ),
    );
  }
}

class CurrentStateScreen extends StatelessWidget {
  const CurrentStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tab 1 (Read-Only)'),
      ),
      body: const ReadOnlyWrapper(
        child: MaintenanceScreen(),
      ),
    );
  }
}
