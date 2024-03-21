import 'package:flutter/material.dart';

class Tab5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Text(
          "User Settings",
          style: TextStyle(fontSize: 24), // Making title bigger and bolder
        ),
      ),
      body: UserSettingsPage(),
    );
  }
}

class UserSettingsPage extends StatefulWidget {
  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  List<User> _users = [];

  TextEditingController _newUsernameController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _newRoleController = TextEditingController();

  TextEditingController _editUsernameController = TextEditingController();
  TextEditingController _editPasswordController = TextEditingController();

  void _addNewUser() {
    String newUsername = _newUsernameController.text;
    String newPassword = _newPasswordController.text;
    String newRole = _newRoleController.text;

    // Add validation logic here

    setState(() {
      _users.add(User(newUsername, newPassword, [newRole]));
    });

    // Clear text fields after adding new user
    _newUsernameController.clear();
    _newPasswordController.clear();
    _newRoleController.clear();
  }

  void _toggleAdminRole(User user) {
    setState(() {
      user.roles.contains('Admin') ? user.roles.remove('Admin') : user.roles.add('Admin');
    });
  }

  void _editUser(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _editUsernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _editPasswordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  user.username = _editUsernameController.text;
                  user.password = _editPasswordController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(User user) {
    setState(() {
      _users.remove(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _newUsernameController,
            decoration: InputDecoration(
              labelText: 'New Username',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _newPasswordController,
            decoration: InputDecoration(
              labelText: 'New Password',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _newRoleController,
            decoration: InputDecoration(
              labelText: 'New Role',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: _addNewUser,
                child: Text("Add New User"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // Logic to toggle admin role
                },
                child: Text("Toggle Admin Role"),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            "User List:",
            style: TextStyle(fontSize: 18),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(_users[index].username),
                    subtitle: Text('Roles: ${_users[index].roles.join(', ')}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editUsernameController.text = _users[index].username;
                            _editPasswordController.text = _users[index].password;
                            _editUser(_users[index]);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.admin_panel_settings),
                          onPressed: () {
                            _toggleAdminRole(_users[index]);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteUser(_users[index]);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class User {
  String username;
  String password;
  List<String> roles;

  User(this.username, this.password, this.roles);
}
