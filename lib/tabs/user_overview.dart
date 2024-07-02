import 'package:alati_app/models/user_model.dart';
import 'package:alati_app/services/user_service.dart';
import 'package:flutter/material.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late UserService userService;
  late Future<List<User>> users;

  @override
  void initState() {
    super.initState();
    userService = UserService('http://10.3.41.24:5001'); // Change to your API base URL
  //http://10.3.41.24:5001/ ovo je za live
  //http://127.0.0.1:5000/api/'; je za test
    users = userService.getUsers();
  }

  void _refreshUsers() {
    setState(() {
      users = userService.getUsers();
    });
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => UserDialog(
        userService: userService,
        onSave: _refreshUsers,
      ),
    );
  }

  void _showEditUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => UserDialog(
        userService: userService,
        user: user,
        onSave: _refreshUsers,
      ),
    );
  }

 void _deleteUser(int id) {
  userService.deleteUser(id).then((_) {
    _refreshUsers();
  }).catchError((error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete user')),
    );
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddUserDialog,
          ),
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: users,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                User user = snapshot.data![index];
                return ListTile(
                  title: Text(user.username),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEditUserDialog(user),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteUser(user.id),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class UserDialog extends StatefulWidget {
  final UserService userService;
  final User? user;
  final VoidCallback onSave;

  const UserDialog({
    super.key,
    required this.userService,
    this.user,
    required this.onSave,
  });

  @override
  _UserDialogState createState() => _UserDialogState();
}

class _UserDialogState extends State<UserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late Map<String, bool> _permissions;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _permissions = widget.user?.permissions ?? {
      'Current state overview': false,
      'Planning': false,
      'Tool Overview': false,
      'Maintenance': false,
      'User settings': false,
    };
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      User user = User(
        id: widget.user?.id ?? 0,
        username: _usernameController.text,
        email: _emailController.text,
        permissions: _permissions,
      );

      if (widget.user == null) {
        widget.userService.addUser(user).then((_) {
          widget.onSave();
          Navigator.of(context).pop();
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add user')),
          );
        });
      } else {
        widget.userService.updateUser(user).then((_) {
          widget.onSave();
          Navigator.of(context).pop();
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update user')),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'Add User' : 'Edit User'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a username';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                return null;
              },
            ),
            ..._permissions.keys.map((key) {
              return CheckboxListTile(
                title: Text(key),
                value: _permissions[key],
                onChanged: (value) {
                  setState(() {
                    _permissions[key] = value!;
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveUser,
          child: Text('Save'),
        ),
      ],
    );
  }
}