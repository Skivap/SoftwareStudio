import 'package:prototype_ss/api/viton_api.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:universal_io/io.dart' as universal_io;


class VitonProvider with ChangeNotifier {
  
  late Map<String, dynamic> userData;
  Map<String, bool> isLoading = {};
  String? link_bd;
  Map<String, String> link_vton = {};
  Map<String, DocumentSnapshot> productData = {};

  String? userId;

  Map<String, bool> getIsLoadingForCart(String cartId) => {cartId: isLoading[cartId] ?? false};

  void loadUserData(String userId){
    this.userId = userId;
    FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get()
      .timeout(const Duration(seconds: 10))
      .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // Handle the retrieved data, e.g., convert to a model or use a Map
        userData = documentSnapshot.data() as Map<String, dynamic>;
        link_bd = userData["bodypic"];
        notifyListeners();
      } else {
        print('No data found for user $userId');
      }

    }).catchError((error) {
      print(userId);
      print("Error getting user data: $error");
    });
  }

  void loadData(String userId, String cartId) async {

    String? prodid;
    await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('cart')
      .doc(cartId)
      .get()
      .timeout(const Duration(seconds: 10))
      .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // Handle the retrieved data, e.g., convert to a model or use a Map
        var data = documentSnapshot.data() as Map<String, dynamic>;
        link_vton[cartId] = data["url"];
        prodid = data["productId"];
        notifyListeners();
      } else {
        print('No data cart found for user $userId');
        return;
      }

    }).catchError((error) {
      print("$userId, $cartId");
      print("Error getting user data: $error");
      return;
    });

    await FirebaseFirestore.instance
      .collection('products')
      .doc(prodid)
      .get()
      .timeout(const Duration(seconds: 10))
      .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        productData[cartId] = documentSnapshot;
        // notifyListeners();
      } else {
        print('No data cart found for user $prodid');
      }

    }).catchError((error) {
      print("$userId, $cartId");
      print("Error getting user data: $error");
    });
    // notifyListeners();
  }

  void generate(cartId, imageUrl) async {
    if(userId == null) return;
    if(isLoading[cartId] == true) return;
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .timeout(const Duration(seconds: 10));

      userData = snapshot.data() as Map<String, dynamic>;

      if (userData != null) {
        if(userData["bodypic"] != null && userData["bodypic"] != ""){
          // TODO: CHANGE THIS AND FETCH THE 
          isLoading[cartId] = true;
          notifyListeners();
          var result = await fetchVitonResult(
            userData["bodypic"],
            imageUrl
          );
          try {
            await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('cart')
              .doc(cartId)
              .update({
                "url": result
              });
              isLoading[cartId] = false;
              link_vton[cartId] = result;
              notifyListeners();
          } catch (e) {
            isLoading[cartId] = false;
            print("Error updating document: $e");
          }
        }
        else{
          isLoading[cartId] = false;
          notifyListeners();
          print("bodypic not found,$userData");
        }
      } else {
        isLoading[cartId] = false;
        notifyListeners();
        print("No document found for cartId: $cartId");
      }
    } catch (e) {
      isLoading[cartId] = false;
      notifyListeners();
      print("Failed to fetch document: $e");
    }
  }

  final ImagePicker _picker = ImagePicker();

  Future<String?> uploadImageWeb(XFile image, Function warning) async {
    try {
      String filename = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('viton/$filename');
      UploadTask uploadTask = storageRef.putData(await image.readAsBytes());
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      warning('Error uploading image: $e');
      return null;
    }
  }

  Future<String?> uploadImage(io.File image, Function warning) async {
    try {
      String filename = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('viton/$filename');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      warning('Error uploading image: $e');
      return null;
    }
  }

  void uploadPictureFromCamera(BuildContext context, Function warning, Function? showUploadDialog) async {
    
    try {

      if(showUploadDialog != null){
        bool shouldUpload = await showUploadDialog(context);
        if (!shouldUpload) {
          print("User chose not to upload an image.");
          return;
        }
      }

      // Capture an image using the camera
      XFile? myimage = await _picker.pickImage(source: ImageSource.camera);
      if (myimage == null) {
        print("Camera capture cancelled; attempting to pick from gallery.");
        myimage = await _picker.pickImage(source: ImageSource.gallery);
        if (myimage == null) {
          print("No image selected from the gallery either.");
          return;
        }
      }
      String? _imageUrl;
      io.File? image_phone = io.File(myimage.path);

      if (universal_io.Platform.isAndroid || universal_io.Platform.isIOS) {
        _imageUrl = await uploadImage(image_phone, warning);
      }
      else {
         _imageUrl = await uploadImageWeb(myimage, warning);
      }
      FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
          "bodypic": _imageUrl
      });
      link_bd = _imageUrl;
      notifyListeners();
    } catch (e) {
      print("Error taking image: $e");
    }
  }

  Future<void> uploadUpdate(io.File? myimage) async{
    if(myimage == null) return;

    io.File? image_phone = io.File(myimage.path);
    String? url;
    try {
      String filename = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('viton/$filename');
      UploadTask uploadTask = storageRef.putFile(myimage);
      TaskSnapshot taskSnapshot = await uploadTask;
      url = await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("error uploading");
      return null;
    }
    try{
      FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
          "bodypic": url
      });
      link_bd = url;
      print("changed body image");
      notifyListeners();
    } catch (e) {
      print("Error taking image: $e");
    }
  }
}