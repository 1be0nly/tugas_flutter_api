import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<User>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Users',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Users'),
        ),
        body: FutureBuilder<List<User>>(
          future: futureUsers,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<User>? users = snapshot.data;
              return ListView(
                children: users!
                    .map((user) => ListTile(
                          title: Text(user.firstName + ' ' + user.lastName),
                          subtitle: Text(user.email),
                        ))
                    .toList(),
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

Future<List<User>> fetchUsers() async {
  final response = await http.get(Uri.parse('https://dummyjson.com/users'));

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response, parse the JSON.
    Map<String, dynamic> parsedJson = jsonDecode(response.body);
    List<dynamic> usersJson = parsedJson['users'];
    return usersJson.map((json) => User.fromJson(json)).toList();
  } else {
    // If the server returns a non-200 response, throw an error.
    throw Exception('Failed to load users');
  }
}

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;

  User(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
    );
  }
}
