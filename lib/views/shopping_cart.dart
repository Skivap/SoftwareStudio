// ignore_for_file: avoid_print, use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prototype_ss/provider/theme_provider.dart';
import 'package:prototype_ss/provider/viton_provider.dart';
import 'package:prototype_ss/widgets/cart_item.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';


class ShoppingCart extends StatefulWidget {
  const ShoppingCart({super.key});

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  late User? _user;
  late String _userId;
  bool isLoading = true;
  bool isLoading2 = false;
  String errorMessage = '';
  late List<Map<String, dynamic>> cartItems = [];
  late Map<String, dynamic> productInfo = {};

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _userId = _user?.uid ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<VitonProvider>(context, listen: false);
        provider.loadUserData(_userId);
      }
    });
    getShoppingCart();
  }

  void getShoppingCart() async {
    try {
      const Duration timeoutDuration = Duration(seconds: 10);
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('cart')
          .get()
          .timeout(timeoutDuration);

      if (querySnapshot.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            cartItems = querySnapshot.docs
                .where((doc) => doc.id != 'defaultCart')
                .map((doc) => {
                  'cartId': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
                .toList();
            isLoading = false;
          });
          await fetchProductInfo();
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = 'No cartItems found';
          });
        }
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Firestore query timed out';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error fetching data from Firestore: $e';
        });
      }
    }
  }

  Future<void> fetchProductInfo() async {
    try {
      List<String> productIds = cartItems.map((item) => item['productId'] as String).toList();
      if (productIds.isEmpty) {
        // If productIds is empty, update the state to reflect no products found
        if (mounted) {
          setState(() {
            productInfo = {};
          });
        }
        return;
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where(FieldPath.documentId, whereIn: productIds)
          .get();

      Map<String, dynamic> data = {};
      for (var doc in querySnapshot.docs) {
        data[doc.id] = doc.data();
      }
      if (mounted) {
        setState(() {
          productInfo = data;
        });
      }
    } catch (e) {
      print('Error fetching product data: $e');
    }
  }

  void removeFromCart(String cartId) async {
    try {
      setState(() {
        isLoading2 = true;
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('cart')
          .doc(cartId)
          .delete();
      if (mounted) {
        setState(() {
          cartItems.removeWhere((item) => item['cartId'] == cartId);
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from cart'),
        ),
      );
    } catch (e) {
      print('Error removing item from cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: SizedBox(
            height: 50, // Adjust the height as needed
            child: Center(
              child: Text('Item removed from cart'),
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        isLoading2 = false;
      });
    }
  }

  void warning(BuildContext context, String error){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }
  void showLoadingDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,  // User cannot dismiss the dialog by tapping outside it
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 24),
                Text(text),  // Optional text to describe the loading action
              ],
            ),
          ),
        );
      },
    );
  }


  void showchange(BuildContext context, ThemeData theme) {
  final provider = Provider.of<VitonProvider>(context, listen: false);
  String? _imageUrl = provider.link_bd;

  io.File? _pickedImage;

  showModalBottomSheet<dynamic>(
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          void updateImage(io.File newImage) {
            setModalState(() {
              _pickedImage = newImage;
              _imageUrl = null;  // Clear previous URL if switching to a file image
            });
          }

          void updateImageUrl(String newUrl) {
            setModalState(() {
              _imageUrl = newUrl;
              _pickedImage = null;  // Clear previous file if switching to a URL
            });
          }

          Future<void> pickImage() async {
            final picker = ImagePicker();
            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              updateImage(io.File(pickedFile.path));
            }
          }

          Future<void> enterImageUrl() async {
            TextEditingController urlController = TextEditingController();
            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Enter Image URL'),
                  content: TextField(
                    controller: urlController,
                    decoration: const InputDecoration(hintText: 'URL'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        updateImageUrl(urlController.text);
                      },
                      child: const Text('Update'),
                    ),
                  ],
                );
              },
            );
          }

          return FractionallySizedBox(
            heightFactor: 0.9,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          "Change Image",
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 30
                          ),
                        ),
                      )
                    ),
                    // Image display and selection handling
                    GestureDetector(
                      onTap: () {
                        if (_pickedImage == null && _imageUrl == null) {
                          pickImage();  // Call to pick an image from gallery
                        } else {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.image),
                                  title: const Text('Change Image from Gallery'),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    pickImage();
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.link),
                                  title: const Text('Enter Image URL'),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    enterImageUrl();
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 500,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: 
                          [
                            ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Center(
                              child: _pickedImage != null ? Image.file(
                                _pickedImage!,
                                fit: BoxFit.cover,
                              ) : (_imageUrl != null ? Image.network(
                                _imageUrl!,
                                fit: BoxFit.cover,
                              ) : Icon(
                                Icons.image,
                                size: 100,
                                color: theme.colorScheme.onSecondary,
                              )),
                            ),
                          ),
                          Center(
                            child: Container(
                              height: 80,  // Set the height of the container
                              width: 80,   // Set the width of the container
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary,
                                border: Border.all(color: theme.colorScheme.onPrimary, width: 5),  // Add a border with a specific color and width
                                borderRadius: BorderRadius.circular(40),  // Make the border circular
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.edit,
                                  color: theme.colorScheme.onPrimary,
                                  size: 40,  // Increase the size of the icon
                                ),
                              ),
                            )
                          ),
                          ]
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                          showLoadingDialog(context, "Processing...");

                          try {
                            // Perform the asynchronous operation and wait for it to finish
                            await provider.uploadUpdate(_pickedImage);
                          } catch (error) {
                            print("Error during operation: $error");
                          }finally {
                            if (mounted) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          }
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return theme.colorScheme.primary.withOpacity(0.5); // Lighten the color when button is pressed
                            } else if (states.contains(MaterialState.disabled)) {
                              return theme.colorScheme.onSurface.withOpacity(0.12);
                            } // Disabled color
                            return theme.colorScheme.primary; // Default color
                          },
                        ),
                        foregroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.grey; // Color when button is disabled
                            }
                            return theme.colorScheme.onPrimary; // Text color
                          },
                        ),
                        elevation: MaterialStateProperty.resolveWith<double>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return 0.0; // No elevation when pressed
                            }
                            return 4.0; // Default elevation
                          },
                        ),
                        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0)), // Padding inside the button
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0), // Rounded corners
                            side: BorderSide(color: theme.colorScheme.primary), // Border color
                          ),
                        ),
                      ),
                      child: const Text('Save'),
                    ),

                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    final theme = Provider.of<ThemeProvider>(context).theme;
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: theme.colorScheme.secondary,
              title: Text(
                'Wardrobe',
                style: TextStyle(
                  fontFamily: 'Abhaya Libre SemiBold', 
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: const Icon(Icons.change_circle_outlined),
                    iconSize: 30,
                    color: theme.colorScheme.onPrimary,
                    onPressed: (){
                      showchange(context, theme);
                    }
                  ),
                ),
              ],
            ),
            backgroundColor: theme.colorScheme.primary,
            body:
            isLoading ? const Center(child: CircularProgressIndicator()) :
            errorMessage.isNotEmpty ? Center(child: Text(errorMessage)) :
            cartItems.isNotEmpty ? 
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.only(top: 30),
                  height: myHeight * 0.92,
                  
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> cartItem = cartItems[index];
                      String cartId = cartItem['cartId'];
                      String productId = cartItem['productId'];
                      Map<String, dynamic> productData = productInfo[productId] ?? {};
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.startToEnd,
                        background: Container(
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Swipe to delete', 
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold
                            )
                          )
                        ),
                        onDismissed: (direction) {
                          removeFromCart(cartId);
                        },
                        child: AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            child: FadeInAnimation(
                              child: CartItemCard(
                                productInfo: productData,
                                cartItemData: cartItem,
                                removeFromCart: () {
                                  removeFromCart(cartId); 
                                  Navigator.pop(context);
                                },
                                userId: _userId,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ):
               Center(
                child: Text(
                  'Your Shopping Cart is empty. Explore our items!',
                  style: TextStyle(color: theme.colorScheme.onPrimary)
                ),
              )
          ),
          if (isLoading2)
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.5)),
              child: const Center(child: CircularProgressIndicator()) 
            ),
        ],
      ),
    );
  }
}
