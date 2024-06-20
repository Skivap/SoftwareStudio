import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype_ss/views/user_settings_views/account_settings.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

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
    getUserInfo();
  }

  void getUserInfo() async {
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
            imageLink = querySnapshot.data()?['imageLink'] ?? '';
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

    return Scaffold(
      appBar: AppBar(
        title:
        Column(
          children: [
            Transform.translate(
              offset: const Offset(0, 10),
              child: const Text(
                'Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontFamily: 'Abhaya Libre SemiBold',
                  fontWeight: FontWeight.w600,
                  height: 3,
                  letterSpacing: -0.41,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: const Divider(
                height: 20,
                thickness: 3,
                indent: 0,
                endIndent: 0,
                color: Colors.black,
              ),
            ), 
          ]
        )
        ),
      body: Padding(
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
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 40),
                      fit: BoxFit.cover,
                      height: 200,
                    ),
                  ),
                  const SizedBox(width: 10,),
                  SizedBox(
                    width: myWidth * 0.4,
                    child: Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
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
                leading: const Icon(Icons.account_circle),
                title: const Text('Account'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettings()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                onTap: () {
      
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Appearance'),
                onTap: () {
      
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Privacy & Security'),
                onTap: () {
      
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help and Support'),
                onTap: () {
      
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About'),
                onTap: () {
      
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: _logout,
              ),
          ],
        ),
      ),
    );
  }
}
