import 'dart:async';
import 'package:flutter/material.dart';
import 'package:SealApp/pages/Login_Page.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a delay to show the splash screen for 3 seconds
    Timer(Duration(seconds: 2), () {
      // After the delay, navigate to the home screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(),));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.white], // Define your desired colors here
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Place your logo or image here
              Image.asset('assets/images/SE.png', width: 150, height: 150),
              SizedBox(height: 20),
              Text(
                ' Seal Management  ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold , color: Colors.blue ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

