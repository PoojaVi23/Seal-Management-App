import 'package:SealApp/pages/Emp_Tracker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:SealApp/pages/Add_Seal_Data.dart';
import 'package:SealApp/pages/Leave_Status.dart';
import 'package:SealApp/pages/User_Profile.dart';
import 'package:SealApp/pages/View_Seal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:SealApp/constants.dart';
import 'package:SealApp/app_classes/My_Drawer.dart';
import 'package:SealApp/app_classes/My_Application_Bar.dart';
import 'package:SealApp/pages/Login_page.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'Employee_Trackers.dart';
import 'Leave_Application.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {

  BarChart? barChart; // Declare barChart variable

  // Add a list to store total_seals_created counts
  List<int> sealCounts = [];

  String lastActiveTime = '';
  String lastfull_name = '';


  String selectedEmployeeId = '';

  List<Map<String, String>> employees = []; // List to store dropdown data

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

  LineChart? lineChart; // Declare lineChart variable
  // List to store parsed data for the chart
  List<FlSpot> chartData = [];
  String? startDate;
  String? endDate;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    getUserLastActiveTime();
    _fetchDropdownData();
    fetchSealData();
  }

  @override
  void dispose() {
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
      _password = prefs.getString('password') ?? '';
      _uuid = prefs.getString('uuid') ?? '';
    });


    if (_isloggedin == false) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }


  Future<void> _fetchDropdownData() async {
    await _getUserDetails();

    final url = '$API_URL/Mobile_flutter_api/get_dropdown_data';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'uuid': _uuid,
        'user_id': _username,
        'password': _password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == '1') {
        setState(() {
          employees = List<Map<String, String>>.from(data['allusers'].map((x) => {
            'id': x['id'] as String,
            'full_name': x['full_name'] as String,
            'username': x['username'] as String,
          }));
        });
      } else {
        throw Exception('Failed to load dropdown data');
      }
    } else {
      throw Exception('Failed to load dropdown data');
    }
  }

  // Define the API function to get user's last active time
  Future<void> getUserLastActiveTime() async {

    await _getUserDetails();

    final url = '$API_URL/Mobile_flutter_api/get_user_last_active_time';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'uuid': _uuid,
        'user_id': _username,
        'password': _password,
        'id': selectedEmployeeId.isNotEmpty ? selectedEmployeeId : _id,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == '1') {
        setState(() {
          lastActiveTime = data['user_data'][0]['dt'];
          lastfull_name = data['user_data'][0]['full_name'];
          lastActiveTime = 'Last active status of Mr.$lastfull_name\nwas on at ${data['user_data'][0]['dt']}';
        });
      } else {
        throw Exception('API returned status: ${data['status']}');
      }
    } else {
      throw Exception('Failed to load user data. Status code: ${response.statusCode}');
    }
  }


  Future<void> fetchSealData() async {
    await _getUserDetails();
    try {
      Map<String, String> requestBody = {
        // 'uuid': '8b79e3ca0663c313',
        'uuid': _uuid,
        'user_id': _username,
        'password': _password,
      };

      if(_user_type == 'S') {
        requestBody['admin_id'] = selectedEmployeeId != null ? selectedEmployeeId : '';
      } else {
        requestBody['admin_id'] = _id;
      }


      final response = await http.post(
        Uri.parse('$API_URL/Mobile_flutter_api/last_five_day_seal_data'),
        headers: {"Accept": "application/json"},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        // Process the data
        sealCounts.clear();
        dataList.forEach((data) {
          String creationDate = data['creation_date'];
          String dayName = data['day_name'];
          int totalSealsCreated = int.parse(data['total_seals_created']);
          sealCounts.add(totalSealsCreated); // Store seal counts
        });

        // Update the UI with the fetched seal counts
        setState(() {
          // Store the fetched seal counts in the state variable
          sealCounts.clear(); // Clear previous seal counts
          dataList.forEach((data) {
            String creationDate = data['creation_date'];
            // print(creationDate);
            int totalSealsCreated = int.parse(data['total_seals_created']);
            sealCounts.add(totalSealsCreated); // Store seal counts
          });

          // Update chart data
          chartData = parseData(dataList);
          fetchDateRange(dataList);
        });

        // print(dataList);
      } else {
        // Handle other status codes if needed
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors or exceptions
      print('Error: $e');
    }
  }

  List<FlSpot> parseData(List<dynamic> dataList) {
    List<FlSpot> spots = [];
    // Map day names to their numerical representations
    Map<String, int> dayNameMap = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };

    for (int i = 0; i < dataList.length; i++) {
      Map<String, dynamic> data = dataList[i];
      String dayName = data['day_name']; // Extract day_name from data
      double x = dayNameMap[dayName]!.toDouble(); // Use numerical representation of day_name as x value
      double y = double.parse(data['total_seals_created']); // y-axis value
      spots.add(FlSpot(x, y));
    }
    return spots;
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
          child: Padding(
            padding: const EdgeInsets.only(left: 08),
            child: Text(
              labelText,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              border: Border.all(
                color: Colors.grey.shade400,
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
    double screenHeight = MediaQuery.of(context).size.height;

    print('Seal counts: $sealCounts'); // Print seal counts

    double calculateMaxY(List<FlSpot> chartData) {
      double max = 0;
      for (FlSpot spot in chartData) {
        if (spot.y > max) {
          max = spot.y;
        }
      }
      return ((max + 9) ~/ 10) * 10; // Round up to the nearest multiple of 10
    }

    Widget? barChart;
    if (chartData.isNotEmpty) {
      List<Color> barColors = [
        Colors.blue, // Color for the first bar
        Colors.green, // Color for the second bar
        Colors.red, // Color for the third bar
        // Add more colors as needed
      ];

      double maxY = calculateMaxY(chartData); // Calculate maxY
      barChart = BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          maxY: maxY, // Dynamically calculate maxY
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(  // ✅ Corrected version
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxY > 10 ? (maxY / 10).floorToDouble() : 1,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < chartData.length) {
                    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    int dayIndex = chartData[index].x.toInt() - 1;
                    if (dayIndex >= 0 && dayIndex < dayNames.length) {
                      return Text(dayNames[dayIndex], style: TextStyle(fontSize: 12));
                    }
                  }
                  return Text('');
                },
                reservedSize: 32,
              ),
            ),
          ),

          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade800,
                width: 2, // Adjust the width as needed
              ),
              left: BorderSide(
                color: Colors.grey.shade800,
                width: 2, // Adjust the width as needed
              ),
            ),
          ),
          barGroups: chartData.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key.toDouble().toInt(), // Cast to int
              barRods: [
                BarChartRodData(
                  toY: entry.value.y,
                  color: barColors[entry.key % barColors.length], // Use color instead of colors
                  width: 16, // Adjust width as needed
                ),

              ],
            );
          }).toList(),
          groupsSpace: 30, // Adjust the spacing between bars as needed
        ),
      );
    } else {
      barChart = null; // Set barChart to null if chartData is empty
    }

    // Calculate the size of the line chart dynamically based on screen dimensions
    double chartWidth = screenWidth * 0.8; // Adjust the multiplier as needed
    double chartHeight = screenHeight * 0.4; // Adjust the multiplier as needed

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        drawer: MyDrawer(
          _full_name, _email, _isloggedin, userImageUrl, _id, _user_type, _password, _uuid,
        ),
        appBar: MyApplicationBar(title: const Text('SEAL MANAGEMENT')),
        body: Stack(
          children: [
            Center(
              child: ClipOval(
                child: Container(
                  height: 350,
                  width: 350,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/SE.png"),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.1),
                        BlendMode.dstATop,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 200, // Increased height
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    child: ClipOval(
                                      child: Image.asset('assets/'
                                          'gif/user.gif'),
                                    ),
                                  ),
                                  Text(
                                    'Hello\nMr. $_full_name!',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 18.0),
                                child: Text(
                                  '$lastActiveTime',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        if (_user_type == 'S')
                          Card(
                            elevation: 5.0,
                            child: buildDropdowns(
                              "Employee Name:",
                              selectedEmployeeId,
                                  (value) {
                                setState(() {
                                  selectedEmployeeId = value!;
                                  fetchSealData();
                                  getUserLastActiveTime();
                                });
                              },
                              employees,
                            ),
                          ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ViewSeal()),
                                  );
                                },
                                icon: Icon(Icons.bar_chart),
                                label: Text(
                                  'Total Seals\n'
                                      '${sealCounts.isNotEmpty ? sealCounts.reduce((value, element) => value + element) : 0}',
                                  style: TextStyle(fontSize: 12), // Adjust the font size as per your requirement
                                ),
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size.fromHeight(50),
                                  backgroundColor: Colors.blue,
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            if (_user_type == 'S') // Condition for Button 1
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => LeaveApplicationStatus()),
                                    );
                                  },
                                  icon: Icon(Icons.calendar_today), // Icon for Button 1
                                  label: Text(
                                    'Leave Status',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12, // Adjust the text size as per your requirement
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size.fromHeight(50), // Adjust the height as per your requirement
                                  ),
                                ),
                              ),
                            SizedBox(width: 5),
                            if (_user_type == 'A' || _user_type == 'U' || _user_type == 'I') // Condition for Button 2
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => LeaveRequest()),
                                    );
                                  },
                                  icon: Icon(Icons.assignment), // Icon for Button 2
                                  label: Text(
                                    'Leave Application',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12, // Adjust the text size as per your requirement
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size.fromHeight(50), // Adjust the height as per your requirement
                                  ),
                                ),
                              ),
                            if (_user_type == 'S') // Condition for Button 1
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => Emp_Tracker(selectedEmployeeName: selectedEmployeeId,)),
                                    );
                                  },
                                  icon: Icon(Icons.location_on_outlined), // Replace `your_icon` with the icon you want to use
                                  label: Text(
                                    'Emp Tracker',
                                    style: TextStyle(fontSize: 12), // Adjust the font size as per your requirement
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size.fromHeight(50), // Adjust the height as per your requirement
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          "Date Range: ${startDate != null ? startDate! : ''} - ${endDate != null ? endDate! : ''}",
                          style: TextStyle(color: Colors.blue),
                        ),
                        SizedBox(height: 14.0),
                        SizedBox(
                          width: chartWidth,
                          height: chartHeight,
                          child: barChart ?? Container(), // Use the barChart widget if not null, otherwise use an empty Container
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          "Reporting of Seal Entries for the Last Seven Days",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddSealData()),
            );
          },
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.blue,
          elevation: 5,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }


  Future<void> fetchDateRange(List<dynamic> dataList) async {
    if (dataList.isNotEmpty) {
      startDate = dataList.last['creation_date'];
      endDate = dataList.first['creation_date'];
    } else {
      startDate = null;
      endDate = null;
    }
  }

  Widget buildDropdowns(String label, String? value, void Function(String?)? onChanged, List<Map<String, String>> employees) {
    // Prepare dropdown items
    List<DropdownMenuItem<String>> dropdownItems = [
      DropdownMenuItem(
        value: '', // Use an empty string as the default value
        child: Text('Select username'), // Displayed text for the default item
      ),
      ...employees.map((employee) {
        return DropdownMenuItem<String>(
          value: employee['id']!,
          child: Text('${employee['full_name']} - (${employee['username']})'),
        );
      }).toList(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Background color of dropdown field
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: DropdownButton<String>(
                      isExpanded: true, // Ensures the dropdown button expands to fill its container
                      hint: Text('Select an employee'), // Hint text
                      value: value!.isEmpty ? null : value, // Ensure value is null for default
                      onChanged: onChanged,
                      items: dropdownItems,
                      underline: Container(), // Removes the default underline
                      style: TextStyle(fontSize: 16.0, color: Colors.black87),
                      icon: Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
