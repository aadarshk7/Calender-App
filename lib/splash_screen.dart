import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/calendar');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/calender.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Text(
            'Welcome to Calendar App',
            style: TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black,
                  offset: Offset(5.0, 5.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
