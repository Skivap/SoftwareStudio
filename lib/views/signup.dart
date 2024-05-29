import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prototype_ss/widgets/authentication.dart';

class SignUpPage extends StatefulWidget {
  final void Function(String) changePage;

  const SignUpPage({super.key, required this.changePage});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final AuthService _authService = AuthService();

  static double padder = 50.0;

  void signUpAccount() async {
    String email = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String name = _nameController.text.trim();

    if (password != confirmPassword) {
      print('Passwords do not match');
      return;
    }
    try {
      User? user = await _authService.signUpWithEmailPassword(email, password, name);
      if (user == null) {
        print('Sign Up Failed');
      } else {
        print('Sign Up Successful: ${user.uid}');
        widget.changePage("Home");
      }
    } catch (e, stackTrace) {
      print('Sign Up Error: $e');
      print('Stack trace: $stackTrace');
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
              child: textForm('Name', _nameController, false),
            ),

            const SizedBox(height: 20.0),

            Padding(
              padding: EdgeInsets.only(left: padder, right: padder),
              child: textForm('Email', _usernameController, false),
            ),

            const SizedBox(height: 20.0),

            Padding(
              padding: EdgeInsets.only(left: padder, right: padder),
              child: textForm('Password', _passwordController, true),
            ),

            const SizedBox(height: 20.0),

            Padding(
              padding: EdgeInsets.only(left: padder, right: padder),
              child: textForm('Confirm Password', _confirmPasswordController, true),
            ),

            const SizedBox(height: 40.0),

            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: signUpAccount,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16),
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
                    top: 6,
                    bottom: 6,
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40.0),

            ElevatedButton(
              onPressed: () => widget.changePage("Login"),
              child: const Text(
                "Already have an account? Login!"
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget textForm(String text, TextEditingController control, bool hide) {
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
