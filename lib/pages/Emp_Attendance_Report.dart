import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:SealApp/constants.dart';
import '../app_classes/My_Application_Bar.dart';
import '../app_classes/My_Drawer.dart';
import '../models/Emp_attendance_TableData.dart';
import 'Login_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class EmpAttendanceReport extends StatefulWidget {
  @override
  _EmpAttendanceReportState createState() => _EmpAttendanceReportState();
}

class _EmpAttendanceReportState extends State<EmpAttendanceReport> {

  //Variables for user selected values
  String? selectedemployee;
  DateTime? Date;


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


  // List to store Employee names
  List<String> employees = [];


  // List to store employee_ids
  List<String> employeeIds = [];

  // List to store Employee names
  List<String> full_name = [];

  bool showStaticTable = false;

  List<Map<String, dynamic>> tableData = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    fetchdropdownData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void toggleStaticTable(bool showTable) {
    setState(() {
      showStaticTable = showTable;
    });
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
          // if (data.containsKey("users")) {
          //   updateLocationData(data["users"]);
          // } else {
          //   print('No "users" data found in the response');
          // }

          if (data.containsKey("allusers")) {
            updateLocationData(data["allusers"]);
          } else {
            print('No "users" data found in the response');
          }

          setState(() {
            selectedemployee = "All Users";
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

  void updateLocationData(List<dynamic> userDataList) {
    employees.clear();
    employeeIds.clear();
    full_name.clear();
    employees.add("All Users");

    for (var userData in userDataList) {
      String employeeName = userData["username"].toString();
      String employeeFullName = userData["full_name"].toString();
      String employeeId = userData["id"].toString();

      employees.add("$employeeFullName ($employeeName)");
      employeeIds.add(employeeId);
    }
  }

  // Define a function to get the location_id for the selected location name
  String? getSelectedEmployeeId() {
    if (selectedemployee != null && selectedemployee != "All Users") {
      int selectedIndex = employees.sublist(employees.indexOf("All Users") + 1).indexOf(selectedemployee!);
      if (selectedIndex != -1 && selectedIndex < employeeIds.length) {
        return employeeIds[selectedIndex];
      }
    }
    return null;
  }



  //Fetching API for Search Seal Data
  Future<void> get_user_attendance_report({String? employeeId})
  async {
    try {
      await _getUserDetails();
      final response = await http.post(
        Uri.parse('$API_URL/Mobile_flutter_api/get_user_attendance_report'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
          'id':employeeId,
          'date':Date != null ? Date?.toLocal().toString() : '',
          // '2019-08-18',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.isNotEmpty && data[0]["attendance_array"] != null && data[0]["attendance_array"].isNotEmpty) {
          populateTableData(data);
          toggleStaticTable(true);
        }
        else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('No Attendance Found'),
                content: Text('There is no attendance found for the selected Name/Date.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          toggleStaticTable(false);
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  // Pass the table data to the buildDynamicTable() function
  void populateTableData(List<dynamic> data) {
    setState(() {
      tableData = data.cast<Map<String, dynamic>>();
    });
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
    double screenWidth = MediaQuery.of(context).size.width;


    String? selectedEmployeeId = getSelectedEmployeeId();
    //print(selectedEmployeeId);

    return Scaffold(
      drawer: MyDrawer(_full_name, _email, _isloggedin, userImageUrl, _id, _user_type,_password,_uuid),
      appBar: MyApplicationBar(title: const Text('SEAL MANAGEMENT')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.circle_notifications,
                      color: Colors.blue.shade900,
                      size: 35, // Adjust the icon size as needed
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Emp Attendance Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                  Card(elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Padding(padding: EdgeInsets.all(screenWidth * 0.02),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SizedBox(height: 16.0),
                        // buildDropdown(
                        //   "All Users",
                        //   "Employee Name:",
                        //   employees,
                        //   selectedemployee,
                        //       (value) {
                        //     setState(() {
                        //       selectedemployee = value;
                        //     });
                        //   },
                        // ),
                        buildDropdownField(),
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

                              get_user_attendance_report
                                (
                                employeeId: selectedEmployeeId,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // Set button color
                            ),
                            child: Text('Get Data'),
                          ),
                        ),
                        SizedBox(height: 16.0),  // You can adjust the height as needed
                        Visibility(
                          visible: showStaticTable,
                          child: SizedBox(
                            height: 400, // Set a specific height or use other constraints
                            child: ListView(
                              children: [buildDynamicTable(tableData)],
                            ),
                          ),
                        )
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

  Widget buildDynamicTable(List<Map<String, dynamic>> data) {
    List<Widget> tableDataWidgets = [];

    for (var item in data) {
      var attendanceArray = item["attendance_array"];
      var attendanceType = item["attendance_type"];

      if (attendanceArray != null && attendanceType != null) {
        List<Widget> eventWidgets = [];

        attendanceType.forEach((key, value) {
          var employeeData = attendanceArray[key.toString()];

          if (employeeData != null)
          {
            employeeData.forEach((name, data) {
              var time = data['time'];
              var address = data["address"];

              if (time != null && address != null) {
                eventWidgets.add(
                  TableData(
                    title: value,
                    data: [
                      ['Employee', 'Time', 'Address'],
                      [name, time, address],
                    ],
                  ),
                );
              }
            });
          }
        });
        tableDataWidgets.add(Column(children: eventWidgets));
      }
    }
    return SingleChildScrollView(child: Column(children: tableDataWidgets));
  }


  Widget buildDropdown(
      String hint,
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
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border.all(
                color: Colors.grey.shade600,
                width: 1.0,
              ),
            ),
            child: Center(
              child: DropdownButtonFormField<String>(
                value: selectedItem,
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                isExpanded: true,
                decoration: InputDecoration.collapsed(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.black),
                ),
                selectedItemBuilder: (BuildContext context) {
                  return items.map<Widget>((String item) {
                    return Center(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList();
                },
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildFieldWithDatePicker(String label,
      DateTime? selectedDate,
      void Function(DateTime?) onDateChanged,) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: InkWell(
            onTap: () async {
              final newSelectedDate = await showDatePicker(
                context: context, // Make sure you have access to the context
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (newSelectedDate != null) {
                onDateChanged(newSelectedDate);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate != null
                        ? '${selectedDate.toLocal()}'.split(' ')[0]
                        : 'Select Date',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: 20.0, // Adjust the size as needed
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDropdownField() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Employee Name:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: GestureDetector(
            onTap: () {
              showEmployeeDialog(context);
            },
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(
                  color: Colors.grey.shade600,
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Text(
                  selectedemployee ?? "Select Employee",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showEmployeeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select User"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: employees.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(employees[index]),
                  onTap: () {
                    setState(() {
                      selectedemployee = employees[index];
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

}







