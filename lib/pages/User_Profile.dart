import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:SealApp/app_classes/My_Drawer.dart';
import 'package:SealApp/app_classes/My_Application_Bar.dart';
import 'package:SealApp/pages/Login_Page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:SealApp/pages/My_Home_Page.dart';
import '../constants.dart';

class User_state extends StatefulWidget {
  @override
  _User_profileState createState() => _User_profileState();
}

class _User_profileState extends State<User_state> {
  final searchStrController = TextEditingController();
  bool _isloggedin = true;
  String _id = '';
  String _username = '';
  String _full_name = '';
  String _email = '';
  String userImageUrl = '';
  String _user_type = '';
  String _password = '';
  String _uuid = '';
  bool hasPunchedIn = false;
  bool hasPunchedOut = false;

  // Variables for Punch Status
  List<bool> punchStatus = [false, false, false, false]; // Morning, Lunch Start, Lunch End, Evening Out

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    _checkPunchStatus(); // Load the punch status
  }

  @override
  void dispose() {
    searchStrController.dispose();
    super.dispose();
  }

  _getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isloggedin = prefs.getBool("loggedin")!; // Check if logged in
      _id = prefs.getString('id')!; // User ID
      _username = prefs.getString('username')!; // Username
      _full_name = prefs.getString('full_name')!; // Full Name
      _email = prefs.getString('email')!; // Email
      _user_type = prefs.getString('user_type') ?? ''; // User Type
      _password = prefs.getString('password') ?? ''; // Password
      _uuid = prefs.getString('uuid') ?? ''; // UUID
    });

    if (!_isloggedin) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _checkPunchStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool morningIn = prefs.getBool('punch_morning_in') ?? false;
    bool lunchStart = prefs.getBool('punch_lunch_start') ?? false;
    bool lunchEnd = prefs.getBool('punch_lunch_end') ?? false;
    bool eveningOut = prefs.getBool('punch_evening_out') ?? false;

    setState(() {
      punchStatus[0] = morningIn;
      punchStatus[1] = lunchStart;
      punchStatus[2] = lunchEnd;
      punchStatus[3] = eveningOut;
    });
  }

  Future<void> _updatePunchStatusInPrefs(String punchType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Store punch status for each punch type
    switch (punchType) {
      case '1': // Morning In
        prefs.setBool('punch_morning_in', true);
        break;
      case '2': // Lunch Start
        prefs.setBool('punch_lunch_start', true);
        break;
      case '3': // Lunch End
        prefs.setBool('punch_lunch_end', true);
        break;
      case '4': // Evening Out
        prefs.setBool('punch_evening_out', true);
        break;
    }

    // Call _checkPunchStatus to refresh the UI
    _checkPunchStatus();
  }

  Future<void> _punchIn() async {
    if (punchStatus[0]) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You have already punched in today!")));
      return;
    }
    setState(() {
      punchStatus[0] = true;
    });
    await _updatePunchStatusInPrefs('1'); // Punch in
  }

  Future<void> _punchOut() async {
    if (punchStatus[3]) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You have already punched out today!")));
      return;
    }
    setState(() {
      punchStatus[3] = true;
    });
    await _updatePunchStatusInPrefs('4'); // Punch out
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        drawer: MyDrawer(_full_name, _email, _isloggedin, userImageUrl, _id, _user_type, _password, _uuid),
        appBar: MyApplicationBar(title: const Text('SEAL MANAGEMENT')),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.5),
                        ),
                      ),
                      CircleAvatar(
                        child: Icon(Icons.person, color: Colors.white, size: 50),
                        backgroundColor: Colors.blue.shade900,
                        radius: 45,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'User Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Card(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.person, color: Colors.blue.shade900),
                        title: Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue.shade900)),
                        subtitle: Text(_full_name, style: TextStyle(fontSize: 16)),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.account_circle, color: Colors.blue.shade900),
                        title: Text('Username', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue.shade900)),
                        subtitle: Text(_username, style: TextStyle(fontSize: 16)),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.email, color: Colors.blue.shade900),
                        title: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue.shade900)),
                        subtitle: Text(_email, style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _punchIn,
                    child: Text(
                      'Punch In',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: punchStatus[0] ? Colors.grey : Colors.green, // Change color based on punch status
                      minimumSize: Size(150, 60), // Adjust height to 60
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _punchOut,
                    child: Text(
                      'Punch Out',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: punchStatus[3] ? Colors.grey : Colors.red, // Change color based on punch status
                      minimumSize: Size(150, 60), // Adjust height to 60
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
