import 'package:flutter/material.dart';

//jos se radi na ovome
class Tab4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Work in Progress',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 228, 26, 26),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
