import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginPage extends StatefulWidget {
  
  final void Function(String) changePage;
  
  const LoginPage({super.key, required this.changePage});

  @override
  State<LoginPage> createState() => _LoginPage();

}

class _LoginPage extends State<LoginPage> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static double padder = 50.0;

  String? username;
  String? password;

  void loginAccount(){

    username = _usernameController.text;
    password = _passwordController.text;

    widget.changePage("Home");
    
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
                  width: 300, // Adjust width as needed
                  height: 100, // Adjust height as needed
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
                        offset: Offset(0, 3), // Offset
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: loginAccount,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(16), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      elevation: 2, 
                      backgroundColor: Color.fromARGB(255, 188, 60, 103),
                      
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 6,
                        bottom: 6
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

                const Text(
                  "Don't have an account yet? Sign Up!"
                ),
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
      fillColor: Color.fromARGB(49, 225, 140, 140),
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


