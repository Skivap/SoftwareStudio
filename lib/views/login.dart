import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:prototype_ss/widgets/authentication.dart';
import 'package:flutter/gestures.dart';

class LoginPage extends StatefulWidget {
  
  final void Function(String) changePage;
  
  const LoginPage({super.key, required this.changePage});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  static double padder = 50.0;

  String? username;
  String? password;

  void loginAccount() async{
    String email = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    if(email== '' && password == '')widget.changePage("Home");
    User? user = await _authService.signInWithEmailPassword(email, password);
    if (user == null){
      print('Login Failed');
      // mau tambah showDialog nanti
    }
    else {
      widget.changePage("Home");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
          body: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/wallpaper.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  width: 300,
                  height: 100,
                  child: Image(image: AssetImage("assets/images/scaled_logo.png")),
                ),
                const SizedBox(height: 50.0),

                Padding(
                  padding: EdgeInsets.only(left: padder, right: padder),
                  child: textForm('Email', _usernameController, false),
                ),

                const SizedBox(height: 20.0),

                Padding(
                  padding: EdgeInsets.only(left: padder, right: padder),
                  child: textForm('Password', _passwordController, true),
                ),

                const SizedBox(height: 40.0),

                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // Shadow color
                        spreadRadius: 2, // Spread radius
                        blurRadius: 5, // Blur radius
                        offset: const Offset(0, 3), // Offset
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: loginAccount,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(12), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      elevation: 2, 
                      backgroundColor: const Color.fromARGB(255, 188, 60, 103),
                      
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16, // Adjust font size as needed
                          fontWeight: FontWeight.bold, // Adjust font weight as needed
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40.0),

                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Don\'t have an account? ',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: 'Sign Up',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () { widget.changePage("SignUp"); }
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );

  }
}

Widget textForm(String text, TextEditingController control, bool hide){
  return TextField(
    controller: control,
    obscureText: hide,
    decoration: InputDecoration(
      filled: true,
      fillColor: const Color.fromARGB(49, 225, 140, 140),
      labelText: text,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.black,
          width: 2,
        ),
      ),
      
    ),
  );
}