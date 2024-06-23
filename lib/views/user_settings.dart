import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:prototype_ss/views/user_settings_views/account_settings.dart';
import 'package:prototype_ss/views/user_settings_views/appearance_settings.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
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

  Future<void> _updateProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      try {
        // Upload to Firebase Storage
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('profile_pictures/$userId')
            .putFile(file);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // Update Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'imageLink': downloadUrl});

        setState(() {
          imageLink = downloadUrl;
        });
      } catch (e) {
        print('Error: $e');
      }
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
      //appBar: AppBar(
      //  title:
        // Column(
        //   children: [
        //     Transform.translate(
        //       offset: const Offset(0, 10),
        //       child: const Text(
        //         'Account',
        //         textAlign: TextAlign.center,
        //         style: TextStyle(
        //           color: Colors.black,
        //           fontSize: 32,
        //           fontFamily: 'Abhaya Libre SemiBold',
        //           fontWeight: FontWeight.w600,
        //           height: 3,
        //           letterSpacing: -0.41,
        //         ),
        //       ),
        //     ),
        //     Transform.translate(
        //       offset: const Offset(0, -20),
        //       child: const Divider(
        //         height: 20,
        //         thickness: 3,
        //         indent: 0,
        //         endIndent: 0,
        //         color: Colors.black,
        //       ),
        //     ), 
        //   ]
        // )
        // ),
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
                  Flexible(
                    child: Image.network(
                      imageLink,
                      errorBuilder: (context, error, stackTrace) =>  Icon(Icons.error, size: 40, color: theme.colorScheme.onPrimary,),
                      fit: BoxFit.cover,
                      height: 200,
                    ),
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
            // Center(
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       InkWell(
            //         onTap: () => {
      
            //         },
            //         child: const Column(
            //           children: [Icon(Icons.wallet, size: 20,), Text('To Pay')]
            //         ),
            //       ),
            //       InkWell(
            //         onTap: () => {
      
            //         },
            //         child: const Column(
            //           children: [Icon(Icons.warehouse_rounded, size: 20,), Text('To Ship')]
            //         ),
            //       ),
            //       InkWell(
            //         onTap: () => {
      
            //         },
            //         child: const Column(
            //           children: [Icon(Icons.local_shipping_rounded, size: 20,), Text('To Receive')
            //           ]
            //         ),
            //       ),
            //       InkWell(
            //         onTap: () => {
      
            //         },
            //         child: const Column(
            //           children: [Icon(Icons.rate_review_rounded, size: 20,), Text('To Rate')]
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height:20),
            ListTile(
                leading:  Icon(Icons.account_circle, color: theme.colorScheme.onPrimary,),
                title:  Text('Account', style: TextStyle(color: theme.colorScheme.onPrimary,)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettings()));
                },
              ),
              ListTile(
                leading:  Icon(Icons.notifications, color: theme.colorScheme.onPrimary,),
                title: Text('Notifications',style: TextStyle(color: theme.colorScheme.onPrimary)),
                onTap: () {
      
                },
              ),
              ListTile(
                leading:  Icon(Icons.color_lens, color: theme.colorScheme.onPrimary,),
                title:  Text('Appearance', style: TextStyle(color: theme.colorScheme.onPrimary)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AppearancePage()));
                },
              ),
              ListTile(
                leading:  Icon(Icons.lock, color: theme.colorScheme.onPrimary,),
                title:  Text('Privacy & Security', style: TextStyle(color: theme.colorScheme.onPrimary)),
                onTap: () {
      
                },
              ),
              ListTile(
                leading:  Icon(Icons.help, color: theme.colorScheme.onPrimary,),
                title:  Text('Help and Support', style: TextStyle(color: theme.colorScheme.onPrimary)),
                onTap: () {
      
                },
              ),
              ListTile(
                leading: Icon(Icons.info, color: theme.colorScheme.onPrimary,),
                title:  Text('About', style: TextStyle(color: theme.colorScheme.onPrimary)),
                onTap: () {
      
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.onPrimary,),
                title:  Text('Logout', style: TextStyle(color: theme.colorScheme.onPrimary)),
                onTap: _logout,
              ),
          ],
        ),
      ),
    );
  }
}
