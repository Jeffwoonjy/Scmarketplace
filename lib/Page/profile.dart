import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scmarketplace/utills/colour.dart';
import 'package:scmarketplace/utills/text_box.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  bool _isDisposed = false;
  bool isProcessing = false;
  File? _profilePicture;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  //edit field
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: hexStringToColor("000000"),
        title: Text(
          "Edit $field",
          style: TextStyle(color: hexStringToColor("ffffff")),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: hexStringToColor("ffffff")),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(color: hexStringToColor("808080")),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          //cancel button
          TextButton(
            child: Text(
              "Cancel",
              style: TextStyle(color: hexStringToColor("ffffff")),
            ),
            onPressed: () => Navigator.pop(context),
          ),

          //save button
          TextButton(
            child: Text(
              "Save",
              style: TextStyle(color: hexStringToColor("ffffff")),
            ),
            onPressed: () => Navigator.of(context).pop(newValue),
          ),
        ],
      ),
    );
    //update firestore
    if (newValue.trim().length > 0) {
      await usersCollection.doc(currentUser.uid).update({field: newValue});
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfilePicture();
  }

  // Download profile image
  Future<File?> downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/profile_picture.jpg');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        print('Failed to download the profile picture.');
        return null;
      }
    } catch (e) {
      print('Error downloading profile picture: $e');
      return null;
    }
  }

  // Function to fetch the profile picture URL from Firestore
  Future<File?> fetchProfilePicture() async {
    final snapshot = await usersCollection.doc(currentUser.uid).get();
    final userData = snapshot.data() as Map<String, dynamic>?;
    final profilePictureUrl = userData?['profilePicture'] as String?;

    if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
      return await downloadImage(profilePictureUrl);
    }
    return null;
  }

  // profile image
  Future<void> pickImage() async {
    if (isProcessing) return;
    isProcessing = true;

    final ImagePicker _imagepicker = ImagePicker();
    final XFile? image = await _imagepicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Upload image to Firebase Storage
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(currentUser.uid! + 'logo1.jpg'); // You can change the file name as per your preference

      final taskSnapshot = await storageRef.putFile(File(image.path));
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Update the profile picture URL in Firestore
      await usersCollection.doc(currentUser.uid).update({'profilePicture': downloadUrl});

      if (!_isDisposed) {
        // Update the profile picture URL in Firestore only if the widget is still mounted
        await usersCollection.doc(currentUser.uid).update({'profilePicture': downloadUrl});
        setState(() {
          _profilePicture = File(image.path);
          isProcessing = false;
        });
      } else {
        isProcessing = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
        backgroundColor: hexStringToColor("FFC0CB"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").doc(currentUser.uid).snapshots(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while waiting for data
            return const CircularProgressIndicator();
          } else if (snapshots.hasError) {
            // Show an error message if there's an error
            return Center(
              child: Text("Error ${snapshots.error}"),
            );
          } else if (snapshots.hasData && snapshots.data!.exists) {
            final userData = snapshots.data!.data();
            if (_profilePicture == null && snapshots.hasData && snapshots.data!.exists) {
              final userData = snapshots.data!.data() as Map<String, dynamic>?;
              final profilePictureUrl = userData?['profilePicture'] as String?;
              if (_profilePicture == null && profilePictureUrl is String) {
                fetchProfilePicture().then((profilePictureFile) {
                  if (profilePictureFile != null) {
                    setState(() {
                      _profilePicture = profilePictureFile;
                    });
                  }
                });
              }
            }
            if (userData != null && userData is Map<String, dynamic>) {
              // Fetch profile from Firestore
              final profilePictureUrl = userData['profilePicture'];
              return ListView(
                children: [
                  const SizedBox(height: 50),
                  // Profile picture
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white, // Add a white background to CircleAvatar
                      backgroundImage: _profilePicture != null
                          ? FileImage(_profilePicture!) // Display the profile picture if available
                          : null, // Set to null when there's no profile picture
                      child: _profilePicture == null
                          ? const Icon(Icons.camera_alt, color: Colors.grey) // Show an icon to indicate the user can tap to pick an image
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  //user email
                  Text(
                    currentUser.uid!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: hexStringToColor("95A5A6")),
                  ),
                  const SizedBox(height: 50),
                  //user details
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      "My details",
                      style: TextStyle(color: hexStringToColor("F1C40F")),
                    ),
                  ),
                  //username
                  MyTextBox(
                    text: userData['username'],
                    sectionName: 'username',
                    onPresed: () => editField('username'),
                  ),
                  //email
                  MyTextBox(
                    text: userData['email'],
                    sectionName: 'email',
                    onPresed: () => editField('email'),
                  ),
                  //address
                  MyTextBox(
                    text: userData['address'],
                    sectionName: 'address',
                    onPresed: () => editField('address'),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  //user post
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      "My Post",
                      style: TextStyle(color: hexStringToColor("F1C40F")),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text("Invalid data format"),
              );
            }
          } else {
            return const Center(
              child: Text("No data available"),
            );
          }
        },
      ),
    );
  }
}
