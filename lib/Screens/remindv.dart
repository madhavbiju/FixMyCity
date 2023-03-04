import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixmycity/Models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fixmycity/Screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemindVerifyPage extends StatefulWidget {
  @override
  _RemindVerifyPageState createState() => _RemindVerifyPageState();
}

class _RemindVerifyPageState extends State<RemindVerifyPage> {
  String? email;

  @override
  void initState() {
    super.initState();
    _fetchEmail();
  }

  void _fetchEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = (prefs.getString('email') ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Please verify the mail sent to ${email} to use the App",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  )),
              SizedBox(
                height: 15,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(150, 50),
                ),
                onPressed: () {
                  _logout();
                },
                child: Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('password');

    FirebaseAuth.instance.signOut();

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => SignInPage()));
  }
}
