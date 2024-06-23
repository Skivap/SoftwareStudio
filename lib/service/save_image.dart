import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data'; // For using Uint8List

Future<String> saveImageToFirebase(String imageUrl, String userId) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      Uint8List imageData = response.bodyBytes;

      final storageRef = FirebaseStorage.instance.ref().child('images/$userId.jpg');

      try {
        UploadTask uploadTask = storageRef.putData(imageData);
        TaskSnapshot snapshot = await uploadTask;
        
        // Optionally, if you want to get the download URL
        String downloadUrl = await snapshot.ref.getDownloadURL();
        print('Image uploaded successfully: $downloadUrl');
        return downloadUrl;
      } catch (e) {
        print('Failed to upload image: $e');
        return "";
      }
    } else {
      print('Failed to download image.');
      return "";
    }
  } catch (e) {
    print('Error occurred: $e');
    return "";
  }
}
