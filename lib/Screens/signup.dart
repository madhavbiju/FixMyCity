import 'package:fixmycity/Screens/login.dart';
import 'package:fixmycity/Screens/verify.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fixmycity/Models/user_model.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _auth = FirebaseAuth.instance;

  String? errorMessage;
  final _formKey = GlobalKey<FormState>();

  final firstNameEditingController = new TextEditingController();
  final secondNameEditingController = new TextEditingController();
  final emailEditingController = new TextEditingController();
  final passwordEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailEditingController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
                onSaved: (value) {
                  firstNameEditingController.text = value!;
                },
              ),
              TextFormField(
                controller: passwordEditingController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
                validator: (value) {
                  if (value!.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
                onSaved: (value) {
                  firstNameEditingController.text = value!;
                },
              ),
              TextFormField(
                controller: firstNameEditingController,
                decoration: InputDecoration(labelText: "First Name"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter your First name";
                  }
                  return null;
                },
                onSaved: (value) {
                  firstNameEditingController.text = value!;
                },
              ),
              TextFormField(
                controller: secondNameEditingController,
                decoration: InputDecoration(labelText: "Last Name"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter your Last name";
                  }
                  return null;
                },
                onSaved: (value) {
                  secondNameEditingController.text = value!;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    signUp(emailEditingController.text,
                        passwordEditingController.text);
                  },
                  child: Text("Sign Up"),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          SignInPage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: Text('Already has an account? Login'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((_) {
          postDetailsToFirestore();
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => VerifyScreen()));
        }).catchError((e) {
          Fluttertoast.showToast(msg: e!.message);
        });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        Fluttertoast.showToast(msg: errorMessage!);
        print(error.code);
      }
    }
  }

  postDetailsToFirestore() async {
    // calling our firestore
    // calling our user model
    // sending these values

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    // writing all the values
    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.firstName = firstNameEditingController.text;
    userModel.secondName = secondNameEditingController.text;
    userModel.isVerified = false;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());

    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(builder: (context) => SignInPage()),
        (route) => false);
  }
}
