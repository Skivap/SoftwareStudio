import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:universal_io/io.dart' as universal_io;
import 'dart:io' as io;


import 'dart:math' as math;

import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:prototype_ss/api/viton_api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prototype_ss/service/save_image.dart';
import 'package:prototype_ss/widgets/generate_text.dart';

class CartItemCard extends StatefulWidget {
  final Map<String, dynamic> productInfo;
  final Map<String, dynamic> cartItemData;
  final void Function() removeFromCart;
  final String userId;

  const CartItemCard({
    super.key,
    required this.productInfo,
    required this.cartItemData,
    required this.removeFromCart,
    required this.userId
  });

  @override
  _CartItemCardState createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard>  {
  late Map<String, dynamic> productInfo;
  late Map<String, dynamic> cartItemData;
  late void Function() removeFromCart;
  late String userId;
  late Map<String, dynamic> userData;

  bool _isMounted = false;
  String? link_vton;
  String? link_bd;

  @override
  void initState(){
    super.initState();
    _loadData();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _loadData() async {
    productInfo = widget.productInfo;
    cartItemData = widget.cartItemData;
    removeFromCart = widget.removeFromCart;
    userId = widget.userId;
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
      } else {
        print('No data found for user $userId');
      }
    }).catchError((error) {
      print("Error getting user data: $error");
    });

  }

  @override
  void didUpdateWidget(covariant CartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the data has changed, then update
    if (oldWidget.productInfo != widget.productInfo ||
        oldWidget.cartItemData != widget.cartItemData) {
      _loadData();
    }
  }

  void _showProductDetails(BuildContext context) {
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Padding(
            padding: const EdgeInsets.all(15.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: ClipRRect(
                    // borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      link_vton ?? productInfo['imageUrl'] ?? '',
                      fit: BoxFit.cover,
                      height: 450,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Text(
                  productInfo['name'] ?? 'Loading...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,

                  ),
                ),
                const SizedBox(height: 10,),
                Text(
                  productInfo.containsKey('price') ? '${productInfo['price']} NTD' : 'Loading...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  productInfo['description'] ?? 'Loading description...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: removeFromCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Remove from Cart',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isLoading = false;

  void generate() async {

    try{
      if(productInfo['viton'] != null && productInfo['viton'] != "") return;
      if(_isLoading) return;

      if(_isMounted){
        setState(() {
          _isLoading = true;
        });
      }

      var result = await fetchVitonResult(
        "https://thumbs.dreamstime.com/b/cheerful-casual-indian-man-full-body-isolated-white-photo-37914698.jpg",
        "https://img.freepik.com/free-photo/blue-t-shirt_125540-727.jpg"
      );

      try {
          // Attempt to update the document in Firestore
          await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc(cartItemData['cartId'])
            .update({
              "url": result
            });
          print("Document successfully updated.");
        } catch (e) {
          // Handle the error
          print("Error updating document: $e");
        }

      if(_isMounted){
        setState(() {
          _isLoading = false;
          print(result);
        });
      }
    }
    catch(e){
      print("error as $e");
      return;
    }
  }

  Widget showResponseWithFutureBuilder(ThemeData theme) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(cartItemData['cartId'])
        .get()
        .timeout(const Duration(seconds: 10)),
      builder: (context, snapshot) {
        if (_isLoading || snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 100,
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          print("Error fetching document: ${snapshot.error}");
          return Container();
        }
        
        if (!snapshot.hasData || snapshot.data!.data() == null) {
          print("Document does not exist or is empty.");
          return Container();
        }
        Map<String, dynamic>? documentData = snapshot.data!.data() as Map<String, dynamic>?;
        if (documentData == null || documentData['url'] == null || documentData['url'] == "") {
          return Container();
        } else {
          link_vton = documentData['url'];
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.onPrimary, // Specify the color of the border
                width: 2.0, // Specify the width of the border
              ),
            //   borderRadius: BorderRadius.circular(15.0), // This sets the radius of the border
            ),
            child: ClipRRect(
              // borderRadius: BorderRadius.circular(15.0),
              child: Image.network(
                documentData['url'] ?? '',
                fit: BoxFit.cover,
                width: 150,
                height: 150,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child; // image has loaded
                  } else {
                    return Center(
                      child: SizedBox(
                        width: 150, // Explicit width for the loader
                        height: 150, // Explicit height for the loader
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  } 
                }
              ),
              
            ),
          );
        }
      },
    );
  }

  final ImagePicker _picker = ImagePicker();

  Future<String?> uploadImageWeb(XFile image) async {
    try {
      String filename = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('viton/$filename');
      UploadTask uploadTask = storageRef.putData(await image.readAsBytes());
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }
  Future<String?> uploadImage(io.File image) async {
    try {
      String filename = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('viton/$filename');
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

  void uploadPictureFromCamera() async {
    try {

      bool shouldUpload = await showUploadDialog(context);
      if (!shouldUpload) {
        print("User chose not to upload an image.");
        return;
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
      io.File? image_phone;

      if (universal_io.Platform.isAndroid || universal_io.Platform.isIOS) {
        _imageUrl = await uploadImage(image_phone!);
      }
      else {
         _imageUrl = await uploadImageWeb(myimage);
      } 
     FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
            "bodypic": _imageUrl
        });
      if(mounted){
        setState(() {
          link_bd = _imageUrl;
        });
      }
    } catch (e) {
      print("Error taking image: $e");
    }
  }

  Future<bool> showUploadDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload Image'),
          content: Text('Please upload your image of your full body'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Dismisses the dialog and returns false
              },
            ),
            TextButton(
              child: Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop(true); // Dismisses the dialog and returns true
              },
            ),
          ],
        );
      },
    ) ?? false; // Return false if dialog is dismissed by back button or tapping outside the dialog
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).theme;
    return Container(
      margin: const EdgeInsets.only(left:20, bottom: 20),
      child: Column(
        children: [
          Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: math.pi/64,
                        child: Container(
                          width: 150, 
                          height: 150, 
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary,
                            border: Border.all(
                              color: theme.colorScheme.onPrimary, // Specify the color of the border
                              width: 2.0, // Specify the width of the border
                            ),
                          ),
                        ),
                      ),
                      Transform.rotate(
                        angle: -math.pi / 16,
                          child: Container(
                          width: 150, 
                          height: 150, 
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            border: Border.all(
                              color: theme.colorScheme.onPrimary, // Specify the color of the border
                              width: 2.0, // Specify the width of the border
                            ),
                          ),
                        ),
                      ),
                      Transform.rotate(
                        angle: -math.pi / 32,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.onPrimary, // Specify the color of the border
                              width: 2.0, // Specify the width of the border
                            ),
                          ),
                          child: ClipRRect(
                            child: Image.network(
                              productInfo['imageUrl'] ?? '',
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: SizedBox(
                                    width: 150, // Explicit width for the loader
                                    height: 150, // Explicit height for the loader
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      showResponseWithFutureBuilder(theme),
                    ]
                  ),
                ],
              ),
            ),
            Container(width: 20,),
            Container(
              padding: const EdgeInsets.all(8.0),
              width: 200,
              child: Column(
                children: [
                  Text(
                    productInfo['name'] ?? 'Loading...',
                    textAlign: TextAlign.center,
                    style:  TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary
                    ),
                  ),
                  const Divider(
                    indent: 30,
                    endIndent: 30,
                  ),  
                  Text(
                    productInfo.containsKey('price') ? '${productInfo['price']} NTD' : 'Loading...',
                    textAlign: TextAlign.center,
                    style:  TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  Container(height: 10,),
                  Row(
                    children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if(link_bd == null){
                            uploadPictureFromCamera();
                          }
                          else{
                            generate();
                          }
                          
                        },
                        style: ElevatedButton.styleFrom(
                          // elevation: 5, // Shadow depth
                          backgroundColor: theme.colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            // side: BorderSide(color: theme.colorScheme.secondary, width: 3)
                          ), 
                        ),
                        child: Text(
                          'Try', 
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold
                          ),
                        ), 
                      ),
                    ),
                    Container(width: 20,),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showProductDetails(context);
                        },
                        style: ElevatedButton.styleFrom(
                          // elevation: 5, // Shadow depth
                          backgroundColor: theme.colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            // side: BorderSide(color: theme.colorScheme.secondary, width: 3)
                          ), 
                        ),
                        child: Text(
                          'Info', 
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold
                          ),
                        ), 
                      ),
                    ),
                    ],
                  )
                ],
              ),
            ),
          ]
        ),
        Container(height: 20,),
        const Divider(
          thickness: 4,
          indent: 80,
          endIndent: 80,
        )
        ]
      ),
    );
  }
}
