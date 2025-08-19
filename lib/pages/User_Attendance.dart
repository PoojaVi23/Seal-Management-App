import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../app_classes/My_Application_Bar.dart';
import '../app_classes/My_Drawer.dart';
import 'package:SealApp/app_classes/Punch_Entry_Row.dart';
import '../constants.dart';
import 'Login_Page.dart';
import 'package:SealApp/pages/Location_Data_Holder.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

class User_attendance extends StatefulWidget {
  @override
  _User_attendanceState createState() => _User_attendanceState();
}

class _User_attendanceState extends State<User_attendance> {

  LocationData? _locationData;


  // Create a list to store the punch status for each entry
  List<bool> punchStatus = [false, false, false, false];

  //Variables for user details
  bool _isloggedin = true;
  String _id = '';
  String _username = '';
  String _full_name = '';
  String _email = '';
  String userImageUrl = '';
  String _user_type = '';
  String _password = '';
  String _uuid = '';
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _initPreferences();
    _getUserDetails();
    _checkPunchStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Method to initialize location
  void _initLocation() async {
    try {
      _locationData = await Location().getLocation();
      if (_locationData != null) {
        double latitude = _locationData!.latitude!;
        double longitude = _locationData!.longitude!;
        print('Latitude: $latitude, Longitude: $longitude');
      } else {
        print('Failed to fetch location data.');
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _resetPunchStatusForToday();
  }

  void _resetPunchStatusForToday() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastPunchDate = prefs.getString('last_punch_date');
    print("Last Punch Date: $lastPunchDate");

    // Get the current date
    String currentDate = DateTime.now().toString().split(' ')[0];
    print("Current Date: $currentDate");

    // If last punch date is null or different from current date, reset punch status
    if (lastPunchDate == null || lastPunchDate != currentDate) {
      print("Asgasgas");
      print("in loop:$lastPunchDate");
      print("in loop:$currentDate");

      setState(() {
        punchStatus = [false, false, false, false];
      });

      // Store the current date as the last punch date
      prefs.setString('last_punch_date', currentDate);
      print("Punch status reset for today");
    }
  }




  //Fetching user details from sharedpreferences
  _getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isloggedin = prefs.getBool("loggedin")!;
      _id = prefs.getString('id')!;
      _username = prefs.getString('username')!;
      _full_name = prefs.getString('full_name')!;
      _email = prefs.getString('email')!;
      _user_type = prefs.getString('user_type') ?? '';
      _password = prefs.getString('password') ?? '';
      _uuid = prefs.getString('uuid') ?? '';
    });

    if (kDebugMode) {
      //print("is logged in$_isloggedin");
    }
    if (_isloggedin == false) {
      // ignore: use_build_context_synchronously
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }
// Method to update punch status in SharedPreferences
  Future<void> _updatePunchStatusInPrefs(String punchType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentDate = DateTime.now().toString().split(' ')[0]; // Get the current date

    // Store the punch type (punch-in or punch-out) with the current date
    prefs.setString('last_punch_status', punchType); // This will save whether it's punch-in or punch-out
    prefs.setString('last_punch_date', currentDate); // This will save the current date

    // Update punch status
    if (punchType == '1') {
      // Morning In
      setState(() {
        punchStatus[0] = true;
      });
    } else if (punchType == '2') {
      // Lunch Start
      setState(() {
        punchStatus[1] = true;
      });
    } else if (punchType == '3') {
      // Lunch End
      setState(() {
        punchStatus[2] = true;
      });
    } else if (punchType == '4') {
      // Evening Out
      setState(() {
        punchStatus[3] = true;
      });
    }

    // Debugging print statements
    print("Updated punch status in SharedPreferences: ${prefs.getString('last_punch_status')}");
    print("Updated punch date in SharedPreferences: ${prefs.getString('last_punch_date')}");
  }
  Future<void> _checkPunchStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the punch status for each punch type from SharedPreferences
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

  Future<String> getAddress(double latitude, double longitude) async {
    final apiKey = 'AIzaSyCdIqus6Zv1nGHQtQA-JmoVxotbLtr1Cv0';
    final endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>;
        if (results.isNotEmpty) {
          final formattedAddress = results[0]['formatted_address'];
          return formattedAddress;
        }
      }
      return 'Address not found';
    } catch (e) {
      print('Error getting address: $e');
      return 'Error';
    }
  }

  //Fetching API for User Attendance
  Future<void> set_user_attendance(String punchType, double? latitude, double? longitude) async {
    print("Bharat: $latitude");
    print("Chaudhari: $longitude");

    try {
      final address = await getAddress(latitude ?? 0.0, longitude ?? 0.0);
      print('Address: $address');

      final response = await http.post(
        Uri.parse('$API_URL/Mobile_flutter_api/set_user_attendance'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
          'punch_type': punchType,
          'locations[lat]': latitude?.toString() ?? '',
          'locations[long]': longitude?.toString() ?? '',
          'location': address ?? ''
        },
      );

      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body: ${response.body}'); // Debugging log

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed API Response: $data');

        // If backend is overriding status, this will reveal it
        if (data['status'] == 'success') {
          print('Punch recorded successfully.');
        } else {
          print('Punch recording failed. Response: $data');
        }
      } else {
        print('Failed to send data. HTTP Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  Future<bool> _onWillPop() async {
    bool exit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (exit != null && exit) {
      SystemNavigator.pop(); // Exit the app
    }

    return exit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(
          _full_name, _email, _isloggedin, userImageUrl, _id, _user_type, _password, _uuid),
      appBar: MyApplicationBar(title: const Text('SEAL MANAGEMENT')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Daily Attendance',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PunchEntryRow(
                title: 'Morning In',
                alternateColor: true,
                onPressed: () {
                  set_user_attendance('1', _locationData?.latitude, _locationData?.longitude);
                  _updatePunchStatusInPrefs('1'); // Update punch status for "Morning In"
                },
                punched: punchStatus[0],
                punchType: '0',
              ),

              PunchEntryRow(
                title: 'Lunch Start',
                alternateColor: false,
                onPressed: () {
                  set_user_attendance('2', _locationData?.latitude, _locationData?.longitude);
                  _updatePunchStatusInPrefs('2'); // Update punch status for "Lunch Start"
                },
                punched: punchStatus[1],
                punchType: '1',
              ),

              PunchEntryRow(
                title: 'Lunch End',
                alternateColor: true,
                onPressed: () {
                  set_user_attendance('3', _locationData?.latitude, _locationData?.longitude);
                  _updatePunchStatusInPrefs('3'); // Update punch status for "Lunch End"
                },
                punched: punchStatus[2],
                punchType: '2',
              ),

              PunchEntryRow(
                title: 'Evening Out',
                alternateColor: false,
                onPressed: () {
                  set_user_attendance('4', _locationData?.latitude, _locationData?.longitude);
                  _updatePunchStatusInPrefs('4'); // Update punch status for "Evening Out"
                },
                punched: punchStatus[3],
                punchType: '3',
              ),

            ],
          ),
        ),
      ),
    );
  }
}