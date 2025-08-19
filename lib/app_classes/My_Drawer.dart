import 'package:flutter/material.dart';
import 'package:SealApp/pages/Leave_Status.dart';
import 'package:SealApp/pages/My_Home_Page.dart';
import '../constants.dart';
import '../pages/Change_Password.dart';
import '../pages/Detail_Report.dart';
import '../pages/Emp_Attendance_Report.dart';
import '../pages/Employee_Trackers.dart';
import '../pages/Gps_Module.dart';
import '../pages/Login_Page.dart';
import '../pages/Seal_Delivery_Details.dart';
import '../pages/Search.dart';
import '../pages/Summary_Reports.dart';
import '../pages/User_Attendance.dart';
import '../pages/User_Profile.dart';
import '../pages/View_Seal.dart';
import 'package:SealApp/pages/Leave_Application.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/View_User.dart';

class MyDrawer extends StatelessWidget {
  final String username;
  final String email;
  final bool isloggedin;
  final String userImageURL;
  final String id;
  final String user_type;
  final String password;
  final String uuid;

  MyDrawer(this.username, this.email, this.isloggedin, this.userImageURL, this.id,this.user_type,this.password,this.uuid);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
            height: 150, // Adjust the height as needed
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {},
                    child: CircleAvatar(
                      radius: 42.0,
                      backgroundImage: AssetImage('assets/images/SE.png'),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Hi, $username',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Email : $email',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),


          buildListTile(Icons.home, 'Home', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => HomePage())
            );
          }),

          // if (user_type == 'A'||user_type == 'I'||user_type == 'U')
          //   buildListTile(Icons.home, 'Dashboard', () {
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => MyHomePages())
          //     );
          //   }),

          if (user_type == 'S')
            buildListTile(Icons.search_outlined, 'Search Seals', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Search()));
            }),

          if (user_type == 'S'|| user_type == 'A' || user_type == 'U' || user_type == 'I')
            buildListTile(Icons.remove_red_eye, 'View Seals', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ViewSeal()));
            }),
          if (user_type == 'S'|| user_type == 'A')
            buildListTile(Icons.location_on, 'GPS Module', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GpsModule())
              );
            }),
          buildListTile(Icons.person, 'Profile', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => User_state())
            );
          }),

          buildListTile(Icons.key_sharp, 'Change Password', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ChangePassword())
            );
          }),

          if (user_type == 'S'|| user_type == 'A'|| user_type == 'U'|| user_type == 'I')
            buildListTile(Icons.calendar_today_rounded, 'User Attendance', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => User_attendance())
              );
            }),

          if (user_type == 'S'|| user_type == 'A'|| user_type == 'U' || user_type == 'I')
            buildListTile(Icons.calendar_today_rounded, 'Leave Application', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LeaveRequest())
              );
            }),
          if (user_type == 'S')
            buildListTile(Icons.track_changes, 'Leave Status', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LeaveApplicationStatus ())
              );
            }),

          if (user_type == 'S')
            buildListTile(Icons.track_changes, 'Employee Tracker', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EmployeeTrackers())
              );
            }),

          if (user_type == 'S')
            buildListTile(Icons.person_4_outlined, 'Users', () {
              Navigator.push(context,
                MaterialPageRoute(
                  builder: (context) => view_user(),
                ),
              );
            }),
          if (user_type == 'S')
            buildListTile(Icons.circle_notifications, 'Summary Report', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SummaryReport())
              );
            }),
          if (user_type == 'S')
            buildListTile(Icons.circle_notifications, 'Emp Attendance Report', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EmpAttendanceReport())
              );
            }),

          if (user_type == 'S'|| user_type == 'A')
            buildListTile(Icons.flight, 'Seal Delivery Details', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SealDeliveryDetails())
              );
            }),

          buildListTile(Icons.logout, 'Logout', () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool("loggedin", false); // Clear the isLoggedIn flag upon logout
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
          }),
        ],
      ),
    );
  }

  ListTile buildListTile(IconData icon, String title, Function() onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue,),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
