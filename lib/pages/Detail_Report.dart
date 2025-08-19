import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:SealApp/constants.dart';
import '../app_classes/My_Application_Bar.dart';
import '../app_classes/My_Drawer.dart';
import 'Login_Page.dart';
import 'package:http/http.dart' as http;

class DetailReport extends StatefulWidget {
  @override
  _DetailReportState createState() => _DetailReportState();
}

class _DetailReportState extends State<DetailReport> {

  //Variables for user selected values
  String? selectedLocation;
  DateTime? Date;

  final searchStrController = TextEditingController();

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


  // List to store location names
  List<String> locations = [];


  // List to store location_id
  List<String> locationIds = [];


  @override
  void initState() {
    super.initState();
    _getUserDetails();
    fetchdropdownData();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    searchStrController.dispose();
    super.dispose();
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
      _password = prefs.getString('password')??'';
      _uuid= prefs.getString('uuid')??'';

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

  //Fetching API for Dropdown
  fetchdropdownData() async {
    await _getUserDetails();
    try {
      final response = await http.post(
        Uri.parse('$API_URL/Mobile_flutter_api/get_dropdown_data'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        //Fetching API for location
        if (data["status"] == "1") {
          if (data.containsKey("location")) {
            updateLocationData(data["location"]);
          } else {
            print('No "location" data found in the response');
          }

          setState(() {
            selectedLocation = "--- All Location ---";
          });

        } else {
          print('Status is not 1 in the response');
        }
      } else {
        print('Failed to fetch Dropdown API. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void updateLocationData(List<dynamic> locationDataList) {
    locations.clear();
    locationIds.clear();
    locations.add("--- All Location ---");

    for (var locationData in locationDataList) {
      String locationName = locationData["location_name"].toString();
      String locationId = locationData["location_id"].toString();

      locations.add(locationName);
      locationIds.add(locationId);
    }
  }

  // Define a function to get the location_id for the selected location name
  String? getSelectedLocationId() {
    if (selectedLocation != null && selectedLocation != "--- All Location ---") {
      int selectedIndex = locations.sublist(locations.indexOf("--- All Location ---") + 1).indexOf(selectedLocation!);
      if (selectedIndex != -1 && selectedIndex < locationIds.length) {
        return locationIds[selectedIndex];
      }
    }
    return null;
  }


  //Fetching API for Search Seal Data
  void fetch_search_seal_data({String? plantId, String? locationId,String? materialId, String? vehicleNumber })
  async {
    try {
      await _getUserDetails();
      final response = await http.post(
        Uri.parse('$API_URL/Mobile_flutter_api/search_seal_data'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
          'location_id':locationId,
          'from_date':Date != null ? Date?.toLocal().toString() : '',
          // '2019-08-18',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        //print("bharat");

      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    String? selectedLocationId = getSelectedLocationId();

    return Scaffold(
      drawer: MyDrawer(_full_name, _email, _isloggedin, userImageUrl, _id, _user_type,_password,_uuid),
      appBar: MyApplicationBar(title: const Text('SEAL MANAGEMENT')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.circle_notifications,
                        color: Colors.blue.shade900,
                        size: 35, // Adjust the icon size as needed
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Detail Report',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  Card(elevation: 4.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
                    child: Padding(padding: const EdgeInsets.all(16.0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SizedBox(height: 16.0),
                        buildDropdown(
                          "Location:",
                          locations,
                          selectedLocation,
                              (value) {
                            setState(() {
                              selectedLocation = value;
                            });
                          },
                        ),
                        SizedBox(height: 16.0),
                        buildFieldWithDatePicker(
                          'Date:',
                          Date,
                              (selectedDate) {
                            setState(() {
                              Date = selectedDate;
                            });
                          },
                        ),
                        SizedBox(height: 24.0), // Increased spacing
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              // print('Location: $selectedLocation');
                              // print('Date: Date');
                              fetch_search_seal_data
                                (
                                locationId: selectedLocationId,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // Set button color
                            ),
                            child: Text('Get Data'),
                          ),
                        ),
                      ],
                      ),
                    ),
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(
      String labelText,
      List<String> items,
      String? selectedItem,
      void Function(String?) onChanged,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            labelText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900, // Set label text color
            ),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedItem,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget buildFieldWithDatePicker(
      String label,
      DateTime? selectedDate,
      void Function(DateTime?) onDateChanged,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900, // Set label text color
          ),
        ),
        InkWell(
          onTap: () async {
            final newSelectedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (newSelectedDate != null) {
              onDateChanged(newSelectedDate);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            padding: EdgeInsets.all(16.0),
            child: Text(
              selectedDate != null
                  ? '${selectedDate.toLocal()}'.split(' ')[0]
                  : 'Select Date',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTextField(
      String labelText,
      String? text,
      void Function(String?) onChanged,
      ) {
    return Row(
      children: [
        Icon(
          Icons.directions_car,
          color: Colors.blue.shade900,
          size: 30.0, // Icon size
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: Text(
            labelText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: TextFormField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Enter Vehicle No',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.blue.shade900, // Border color
                ),
              ),
            ),
            style: TextStyle(
              fontSize: 18,
              color: Colors.blue.shade900, // Text input color
            ),
          ),
        ),
      ],
    );
  }
}

