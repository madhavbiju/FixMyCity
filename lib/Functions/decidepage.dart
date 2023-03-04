import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixmycity/models/user_model.dart';
import 'package:fixmycity/Screens/home.dart';
import 'package:fixmycity/Screens/remindv.dart';

class VerifyCheckPage extends StatefulWidget {
  @override
  _VerifyCheckPageState createState() => _VerifyCheckPageState();
}

class _VerifyCheckPageState extends State<VerifyCheckPage> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    pullData();
  }

  void decidePage() {
    print("Hello2${loggedInUser.isVerified}");
    if (loggedInUser.isVerified == true) {
      setState(() {
        _isLoading = true;
      });
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => RemindVerifyPage()));
    }
  }

  void pullData() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      print("Hello1${loggedInUser.isVerified}");
      decidePage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
