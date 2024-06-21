import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
//import 'package:intl/intl.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() {
    return _AccountSettings();
  }
}

class _AccountSettings extends State<AccountSettings> {
  late User? user;
  late String? userId;
  String imageLink = '';
  String username = '';
  String gender = '';
  String email = '';
  String phone = '';
  var birthday = DateTime.now();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  //final TextEditingController _birthdayController = TextEditingController();

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
            gender = querySnapshot.data()?['gender'] ?? 'Male';
            email = querySnapshot.data()?['email'] ?? '';
            phone = querySnapshot.data()?['phone'] ?? '';
            //birthday = (querySnapshot.data()?['birthday'] as Timestamp).toDate() ?? birthday;

            _nameController.text = username;
            _emailController.text = email;
            _phoneController.text = phone;
           // _birthdayController.text = DateFormat('yyyy-MM-dd').format(birthday);
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

  Future<void> updateUserInfo() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': _nameController.text,
        'gender': gender,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'imageLink': imageLink,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images/$userId.jpg');
      final UploadTask uploadTask = storageReference.putFile(imageFile);

      final TaskSnapshot downloadUrl = await uploadTask;
      final String url = await downloadUrl.ref.getDownloadURL();

      setState(() {
        imageLink = url;
      });
    }
  }

  Widget buildTextField(
      String labelText, TextEditingController controller, String hintText, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        readOnly: isEditable,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(bottom: 5),
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double myWidth = MediaQuery.of(context).size.width;
    double myHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: myHeight * 0.18,
              decoration: const BoxDecoration(color: Color.fromRGBO(244, 40, 53, 32)),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 120 > myWidth * 0.175 ? myWidth * 0.175 : 120,
                      height: 120 > myWidth * 0.175 ? myWidth * 0.175 : 120,
                      decoration: BoxDecoration(
                        border: Border.all(width: 4, color: Colors.white),
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 2,
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 10),
                          )
                        ],
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(imageLink),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 4,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          color: Color.fromRGBO(244, 40, 53, 32),
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
                  buildTextField("Name", _nameController, username, false),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: DropdownButtonFormField<String>(
                      value: gender.isNotEmpty ? gender : null,
                      items: ['Male', 'Female', 'Other']
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(bottom: 5),
                        labelText: 'Gender',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  buildTextField("Email", _emailController, email, true),
                  buildTextField("Phone", _phoneController, '', false),
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
                          backgroundColor: Color.fromRGBO(244, 40, 53, 32),
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