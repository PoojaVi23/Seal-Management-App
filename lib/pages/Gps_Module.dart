import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:SealApp/app_classes/My_Drawer.dart';
import 'package:SealApp/app_classes/My_Application_Bar.dart';
import 'package:SealApp/pages/Login_Page.dart';
import 'package:SealApp/pages/Add_Gps.dart';


class GpsModule extends StatefulWidget {
  const GpsModule({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _GpsModuleState createState() => _GpsModuleState();
}

class _GpsModuleState extends State<GpsModule> {
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


  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    searchStrController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(_full_name, _email, _isloggedin, userImageUrl, _id, _user_type,_password,_uuid),
      appBar: MyApplicationBar(title: const Text('SEAL MANAGEMENT')),
      body: Card(
        elevation: 12,
        margin:EdgeInsets.all(16),
        child: Container(
          height: 50,
          margin:EdgeInsets.only(left: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'GPS Transactions ',
                style: TextStyle(
                    fontSize: 20,
                    // fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline_outlined,
                  color: Colors.blue.shade900,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddGps()),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
