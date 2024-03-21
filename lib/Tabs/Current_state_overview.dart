import 'package:alati_app/Tabs/Maintenace.dart';
import 'package:flutter/material.dart';


class ReadOnlyWrapper extends StatelessWidget {
  final Widget child;

  const ReadOnlyWrapper({Key? key, required this.child}) : super(key: key);

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

class Tab1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tab 1 (Read-Only)'),
      ),
      body: ReadOnlyWrapper(
        child: Tab4(),
      ),
    );
  }
}
