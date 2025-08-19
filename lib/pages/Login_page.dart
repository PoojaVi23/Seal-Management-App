import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:SealApp/constants.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Location_Data.dart';
import 'My_Home_Page.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'dart:math' as math;


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final myUserName = TextEditingController();
  final myPasswordController = TextEditingController();
  late SharedPreferences _prefs;

  bool _obscureText = true;

  bool isLoggedIn = false;
  bool _loading = false;
  String userId = '';
  String username = '';
  String email = '';


  late Timer _gpsCheckTimer;

  String? _deviceID;
  String? _version;

  final Location _location = Location();
  LocationData? _previousLocation;


  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializePrefs();
    _getDeviceInfo();

    getlocation().then((_) {
      _gpsCheckTimer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
        _updateLocation();
      });
    });
  }

  void _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    // Check for auto-login after initializing _prefs
    _checkAutoLogin();
  }


  // Clean up the controller when the widget is disposed.
  @override
  void dispose() {
    myUserName.dispose();
    myPasswordController.dispose();
    _gpsCheckTimer.cancel();
    super.dispose();
  }

  Location location = new Location();
  bool _serviceEnabled = true;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  Future<void> getlocation() async {
    try {
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) return;
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) return;
      }

      _locationData = await location.getLocation();
      LocationDataHolder.setLocationData(_locationData); // ✅ Store globally
      print("Location Fetched: ${_locationData.latitude}, ${_locationData.longitude}");
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  // Haversine formula to calculate distance between two coordinates
  double degToRad(double deg) {
    return deg * (math.pi / 180);
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const int R = 6371000; // Earth radius in meters
    double dLat = degToRad(lat2 - lat1);
    double dLon = degToRad(lon2 - lon1);
    double a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(degToRad(lat1)) * math.cos(degToRad(lat2)) * math.pow(math.sin(dLon / 2), 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }



  Future<void> updateLocation(double latitude, double longitude) async {
    // Construct the API URL
    String url = '${API_URL}Mobile_flutter_api/update_location';

    // Prepare the request body
    var requestBody = {
      'uuid': _deviceID ?? '',
      'user_id': myUserName.text,
      'password': myPasswordController.text,
      'locations[lat]':latitude.toString(),
      'locations[long]':longitude.toString(),

    };

    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {"Accept": "application/json"},
        body: requestBody,
      );

      // Handle the response
      if (response.statusCode == 200) {
        // Request successful
        print('Location updated successfully');
      } else {
        // Request failed
        print('Failed to update location. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Error updating location: $e');
    }
  }

  void _updateLocation() async {
    try {
      LocationData? currentLocation = LocationDataHolder.locationData; // ✅ Fetch safely
      if (currentLocation == null) {
        print("Location data not available yet.");
        return;
      }

      double latitude = currentLocation.latitude!;
      double longitude = currentLocation.longitude!;

      if (_previousLocation != null) {
        double distance = calculateDistance(
            _previousLocation!.latitude!, _previousLocation!.longitude!,
            latitude, longitude
        );

        if (distance >= 5000) {
          await updateLocation(latitude, longitude);
          _previousLocation = currentLocation;
        }
      } else {
        await updateLocation(latitude, longitude);
        _previousLocation = currentLocation;
      }
    } catch (e) {
      print('Error updating location: $e');
    }
  }




  Future<void> _getDeviceInfo() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      try {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        setState(() {
          _version = androidInfo.version.release;
          _deviceID = androidInfo.id; // Use 'id' instead of 'androidId'
          print(_version);
          print(_deviceID);
        });
      } catch (e) {
        print('Error getting device info: $e');
      }
    });
  }

  void _checkAutoLogin() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool("loggedin") ?? false;

    if (isLoggedIn) {
      // If the user has logged in before, attempt auto-login
      String username = prefs.getString("username") ?? "";
      String password = prefs.getString("password") ?? "";

      if (username.isNotEmpty && password.isNotEmpty) {

        // Set the initial values for text fields
        myUserName.text = username;
        myPasswordController.text = password;
        // Perform auto-login after setting initial values

        setState(() {
          isLoading = true;
        });

        Navigator.push(context, MaterialPageRoute(builder: (context) =>  HomePage()));

      } else {
        print("Username or password is empty. Cannot perform auto-login.");
      }
    } else {
      print("Auto-login skipped: User not logged in before.");
    }
  }


  bidderLogin(String username, String password) async {
    String url = '${API_URL}/Mobile_flutter_api/verify_user'; // Ensure API_URL is correct

    var data = {
      'uuid': _deviceID ?? '',
      'user_id': username,
      'password': password,
      'app_version': _version ?? ''
    };

    // 🔍 DEBUGGING PRINTS
    print("Login API URL: $url");
    print("Sending Login Request: $data");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Accept": "application/json"},
        body: data,
      );

      // 🔍 DEBUGGING PRINTS (AFTER API RESPONSE)
      print("API Response Status Code: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      var resStr = json.decode(response.body);

      if (resStr['status'] == '1') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("loggedin", true);
        prefs.setString("id", resStr['user_data']['id'].toString());
        prefs.setString("username", resStr['user_data']['username'].toString());
        prefs.setString("full_name", resStr['user_data']['full_name'].toString());
        prefs.setString("user_type", resStr['user_data']['user_type'].toString());
        prefs.setString("email", resStr['user_data']['email'].toString());
        prefs.setString("mat_id", resStr['user_data']['mat_id'].toString());
        prefs.setString("password", password);
        prefs.setString("uuid", _deviceID ?? '');

        isLoggedIn = true;
        setState(() {
          isLoading = false;
        });

        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        setState(() {
          isLoading = false;
        });

        print("Login Failed: ${resStr['message']}");

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Invalid Login/Password"),
              content: Text(resStr['message'].toString()), // Show API error message
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print("Error during login request: $e");

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("SERVER ERROR: $e"),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildUserNameTF() {

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "User Name",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
              controller: myUserName,
              decoration: const InputDecoration(
                hintText: "Enter your User Name",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                suffixIcon: InkWell(
                  child: Icon(
                    Icons.account_box_rounded,
                    size: 20.0,
                    color: Colors.black,
                  ),
                ),
              )
          )
        ]
    );
  }

  Widget _buildPasswordTF() {
    SharedPreferences _prefs; // Declare _prefs variable here

    // Initialize SharedPreferences
    // SharedPreferences.getInstance().then((prefs) {
    //   _prefs = prefs;
    //   // Retrieve password from SharedPreferences
    //   String storedPassword = _prefs.getString("password") ?? "";
    //   myPasswordController.text = storedPassword; // Set initial value
    // });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Password",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        TextField(
          controller: myPasswordController,
          obscureText: _obscureText,
          decoration: InputDecoration(
            hintText: "Enter your Password",
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            suffixIcon: InkWell(
              onTap: _toggle,
              child: Icon(
                _obscureText ? Icons.remove_red_eye : Icons.visibility_off,
                size: 20.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildLoginBtn() {
    return GestureDetector(
      onTap: () {
        if (_formKey.currentState!.validate()) {
          // If the form is valid, display a Snackbar.
          String username = myUserName.text.trim();
          String password = myPasswordController.text.trim();
          bidderLogin(username, password);
          setState(() {
            isLoading = true;
          });
        }
      },
      child: Container(
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: 50),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.lightBlueAccent, Colors.blue]
          ),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
          ),
        )
            : const Text(
          'Login',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  colors: [
                    Colors.blue.shade300,
                    Colors.blue.shade400,
                    Colors.blue.shade500,
                  ]
              )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Center(
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 48,
                        child: ClipOval(
                          child: Image.asset('assets/images/SE.png'),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Seal Management',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white
                        ),
                      ),
                    ],
                  )
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(40),topRight: Radius.circular(40))
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            Text(
                              'Login Page',
                              style: TextStyle(
                                fontSize: 19,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 30),
                            Container(
                              padding:EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [BoxShadow(
                                      color: Colors.blue.shade100,
                                      blurRadius: 20,
                                      offset: Offset(0,10)
                                  )]
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                    ),
                                    child:  _buildUserNameTF(),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                    ),
                                    child:  _buildPasswordTF(),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            _buildLoginBtn(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}












