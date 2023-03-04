import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixmycity/Screens/home.dart';
import 'package:fixmycity/Screens/signUp.dart';
import 'package:fixmycity/Functions/decidepage.dart';

late String gUid;

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  String getUid() {
    final User? user = auth.currentUser;
    final String uid = user!.uid;
    return uid;
  }

  bool _isLoading = false;
  bool _isLoginForm = true;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  // Check if the user is already logged in
  void _checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    String? uid = prefs.getString('uid');
    if (email != null && password != null) {
      setState(() {
        _isLoading = true;
      });
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((user) {
        gUid = uid!;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()));
        print('Helloooooooo');
      }).catchError((error) {
        print(error);
      });
    }
  }

  // Perform sign in or sign up
  void _submit() async {
    if (_formKey.currentState?.validate() == true) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      FirebaseAuth firebaseAuth = FirebaseAuth.instance;

      if (_isLoginForm) {
        // Login
        firebaseAuth
            .signInWithEmailAndPassword(email: email, password: password)
            .then((user) async {
          // Store the user session
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('email', email);
          prefs.setString('password', password);
          String uid = getUid();
          prefs.setString('uid', uid);
          gUid = uid;
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => VerifyCheckPage()));
        }).catchError((error) {
          setState(() {
            _isLoading = false;
          });
          print(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        child: Text('Sign In'),
                        onPressed: _submit,
                      ),
                SizedBox(
                  height: 20.0,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            HomePage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Text('Forgot password?'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            SignUpPage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Text('Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
