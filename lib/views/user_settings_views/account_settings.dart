import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:universal_io/io.dart' as universal_io;

class AccountSettings extends StatefulWidget {
  final Function(String? userId) superGetUserInfo;

  const AccountSettings({
    super.key,
    required this.superGetUserInfo
  });

  @override
  State<AccountSettings> createState() {
    return _AccountSettings();
  }
}

class _AccountSettings extends State<AccountSettings> {
  late User? user;
  late String? userId;
  late Function(String? userId) superGetUserInfo;
  String profileLink = 'https://free-icon-rainbow.com/i/icon_01993/icon_019930_256.jpg'; 
  String username = '';
  String gender = '';
  String email = '';
  String phone = '';
  var birthday = DateTime.now();

  io.File? _pickedImage;
  String? _imageUrl;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    userId = user?.uid ?? '';
    getUserInfo();
    superGetUserInfo = widget.superGetUserInfo;
  }

  Future<void> getUserInfo() async {
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
            username = querySnapshot.data()?['username'] ?? '';
            profileLink = querySnapshot.data()?['profileLink'] ?? '';
            gender = querySnapshot.data()?['gender'] ?? 'Male';
            email = querySnapshot.data()?['email'] ?? '';
            phone = querySnapshot.data()?['phone'] ?? '';

            _nameController.text = username;
            _emailController.text = email;
            _phoneController.text = phone;
          });

          // Fetch and apply the user's theme
          String themeName = querySnapshot.data()?['theme'] ?? 'classicLightTheme';
          Provider.of<ThemeProvider>(context, listen: false).setThemeByName(themeName);
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

  Future<void> updateUserInfo() async {
    try {
      // Upload the image if a new image is picked
      if (_pickedImage != null) {
        _imageUrl = await uploadImage(_pickedImage!);
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'username': _nameController.text,
        'gender': gender,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'profileLink': _imageUrl ?? profileLink,
      });
      
      superGetUserInfo(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      print('Error: $e');
      try{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
      catch(e){}
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedImage != null) {
      setState(() {
        _pickedImage = io.File(pickedImage.path);
      });
      uploadImage(_pickedImage!).then((url) {
        if (url != null && mounted) {
          setState(() {
            _imageUrl = url;  // Update image URL and UI
          });
        }
      }).catchError((error) {
        print("Failed to upload image: $error");
      });
    }
  }

  Future<String?> uploadImage(io.File image) async {
    try {
      String filename = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/$filename');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  Widget buildTextField(
    BuildContext context,
      String labelText, TextEditingController controller, String hintText, bool isEditable) {

    final theme = Provider.of<ThemeProvider>(context).theme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        readOnly: isEditable,
        style: TextStyle(color: theme.colorScheme.onPrimary),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(bottom: 5),
          labelText: labelText,
          labelStyle: TextStyle(
            color: theme.colorScheme.onPrimary
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double myWidth = MediaQuery.of(context).size.width;
    double myHeight = MediaQuery.of(context).size.height;
    final theme = Provider.of<ThemeProvider>(context).theme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.secondary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: theme.colorScheme.primary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: myHeight * 0.18,
              decoration: BoxDecoration(color: theme.colorScheme.tertiary),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 60 > myWidth * 0.0875 ? myWidth * 0.0875 : 60,
                      backgroundImage: NetworkImage(_imageUrl != null ? _imageUrl! : profileLink),
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: 
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 4,
                            color: Colors.white,
                          ),
                          color: theme.colorScheme.tertiary,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  buildTextField(context, "Name", _nameController, username, false),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: DropdownButtonFormField<String>(
                      dropdownColor: theme.colorScheme.secondary,
                      value: gender.isNotEmpty ? gender : null,
                      items: ['Male', 'Female', 'Other']
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(
                                  label,
                                  style: TextStyle(color: theme.colorScheme.onPrimary)
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if(mounted){
                          setState(() {
                            gender = value!;
                          });
                        }
                        
                      },
                      decoration:  InputDecoration(
                        contentPadding: const EdgeInsets.only(bottom: 5),
                        labelText: 'Gender',
                        labelStyle: TextStyle(color: theme.colorScheme.onPrimary),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  buildTextField(context, "Email", _emailController, email, true),
                  buildTextField(context,"Phone", _phoneController, '', false),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "CANCEL",
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: updateUserInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "SAVE",
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
