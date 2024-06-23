import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:prototype_ss/views/user_settings_views/account_settings.dart';
import 'package:prototype_ss/views/user_settings_views/appearance_settings.dart';
import 'package:provider/provider.dart';

class UserSettings extends StatefulWidget {
  final void Function(String) changePage;

  const UserSettings({super.key, required this.changePage});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  late User? user;
  late String? userId;
  String imageLink = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    userId = user?.uid ?? '';
    getUserInfo(userId);
  }

  void getUserInfo(String? userId) async {
    try {
      const Duration timeoutDuration = Duration(seconds: 10);
      DocumentSnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .timeout(timeoutDuration);

      if (querySnapshot.exists) {
        if (mounted) {
          setState(() {
            username = querySnapshot.data()?['name'] ?? '';
            imageLink = querySnapshot.data()?['profileLink'] ?? '';
          });
        }
      } else {
        if (mounted) {
          print('Document does not exist');
        }
      }
    } on TimeoutException catch (_) {
      print('Timeout occurred');
    } catch (e) {
      print('Error: $e');
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    widget.changePage('Login');
  }

  @override
  Widget build(BuildContext context) {
    double myWidth = MediaQuery.of(context).size.width;
    double myHeight = MediaQuery.of(context).size.height;
    final theme = Provider.of<ThemeProvider>(context).theme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.secondary,
        title: Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Abhaya Libre SemiBold', 
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: theme.colorScheme.primary),
        padding: EdgeInsets.all(myWidth * 0.02),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: myHeight * 0.125,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: myWidth * 0.1,
                    backgroundImage: imageLink.isNotEmpty ? NetworkImage(imageLink) : null,
                    backgroundColor: Colors.grey.shade300,
                    child: imageLink.isEmpty ? Icon(Icons.person, size: 40, color: theme.colorScheme.onPrimary) : null,
                  ),
                  const SizedBox(width: 10,),
                  SizedBox(
                    width: myWidth * 0.4,
                    child: Text(
                      username,
                      style:  TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height:20),
            ListTile(
              leading: Icon(Icons.account_circle, color: theme.colorScheme.onPrimary),
              title: Text('Account', style: TextStyle(color: theme.colorScheme.onPrimary)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettings()));
              },
            ),
            ListTile(
              leading: Icon(Icons.color_lens, color: theme.colorScheme.onPrimary),
              title: Text('Appearance', style: TextStyle(color: theme.colorScheme.onPrimary)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AppearancePage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.help, color: theme.colorScheme.onPrimary),
              title: Text('Help and Support', style: TextStyle(color: theme.colorScheme.onPrimary)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.info, color: theme.colorScheme.onPrimary),
              title: Text('About', style: TextStyle(color: theme.colorScheme.onPrimary)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.onPrimary),
              title: Text('Logout', style: TextStyle(color: theme.colorScheme.onPrimary)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
