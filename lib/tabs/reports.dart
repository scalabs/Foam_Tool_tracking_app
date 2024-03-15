import 'package:flutter/material.dart';

class Tab5 extends StatelessWidget {
  const Tab5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Settings"),
      ),
      body: const UserSettingsPage(),
    );
  }
}

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  String _username = "JohnDoe";
  String _password = "password123";
  bool _isAdmin = false;

  void _generateNewPassword() {
    // Generate a new random password logic
    setState(() {
      _password = _generateRandomPassword();
    });
  }

  String _generateRandomPassword() {
    // Your logic to generate a random password
    return "newPassword123";
  }

  void _changeUsername(String newUsername) {
    setState(() {
      _username = newUsername;
    });
  }

  void _toggleAdminRole() {
    setState(() {
      _isAdmin = !_isAdmin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Username: $_username",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            "Password: $_password",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _generateNewPassword,
            child: const Text("Generate New Password"),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: const InputDecoration(
              labelText: 'New Username',
            ),
            onChanged: _changeUsername,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                "Role: ${_isAdmin ? 'Admin' : 'User'}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 10),
              Switch(
                value: _isAdmin,
                onChanged: (bool value) {
                  _toggleAdminRole();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
