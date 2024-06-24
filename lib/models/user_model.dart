import 'dart:convert';

class User {
  final int id;
  final String username;
  final String email;
  final Map<String, bool> permissions;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      permissions: Map<String, bool>.from(jsonDecode(json['permissions'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'permissions': jsonEncode(permissions),
    };
  }
}
