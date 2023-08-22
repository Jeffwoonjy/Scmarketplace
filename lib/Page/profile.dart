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
import 'package:scmarketplace/vendor/views/auth/vendor_auth_screen.dart';
import 'package:scmarketplace/vendor/views/auth/vendor_registration_screen.dart';
import 'package:scmarketplace/vendor/views/screens/main_vendor_screen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
  List<Review> userReviews = [];
  TextEditingController _reviewController = TextEditingController();
  double selectedRating = 0.0;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

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
          TextButton(
            child: Text(
              "Cancel",
              style: TextStyle(color: hexStringToColor("ffffff")),
            ),
            onPressed: () => Navigator.pop(context),
          ),
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

    if (newValue.trim().length > 0) {
      await usersCollection.doc(currentUser.uid).update({field: newValue});
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfilePicture();
  }

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

  Future<File?> fetchProfilePicture() async {
    final snapshot = await usersCollection.doc(currentUser.uid).get();
    final userData = snapshot.data() as Map<String, dynamic>?;
    final profilePictureUrl = userData?['profilePicture'] as String?;

    if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
      return await downloadImage(profilePictureUrl);
    }
    return null;
  }

  Future<void> pickImage() async {
    if (isProcessing) return;
    isProcessing = true;

    final ImagePicker _imagepicker = ImagePicker();
    final XFile? image = await _imagepicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(currentUser.uid! + 'logo1.jpg');

      final taskSnapshot = await storageRef.putFile(File(image.path));
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      await usersCollection.doc(currentUser.uid).update({'profilePicture': downloadUrl});

      if (!_isDisposed) {
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VendorRegistrationScreen()),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              child: const Text(
                "Seller Page",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").doc(currentUser.uid).snapshots(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshots.hasError) {
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
              final profilePictureUrl = userData['profilePicture'];
              return ListView(
                children: [
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white,
                      backgroundImage: _profilePicture != null ? FileImage(_profilePicture!) : null,
                      child: _profilePicture == null ? const Icon(Icons.camera_alt, color: Colors.grey) : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentUser.uid!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: hexStringToColor("95A5A6")),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      "My details",
                      style: TextStyle(color: hexStringToColor("F1C40F")),
                    ),
                  ),
                  MyTextBox(
                    text: userData['username'],
                    sectionName: 'username',
                    onPresed: () => editField('username'),
                  ),
                  MyTextBox(
                    text: userData['email'],
                    sectionName: 'email',
                    onPresed: () => editField('email'),
                  ),
                  MyTextBox(
                    text: userData['address'],
                    sectionName: 'address',
                    onPresed: () => editField('address'),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      "My Post",
                      style: TextStyle(color: hexStringToColor("F1C40F")),
                    ),
                  ),

                  // Review section
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Reviews",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        RatingBar.builder(
                          initialRating: selectedRating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 30.0,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            setState(() {
                              selectedRating = rating;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Write your review...',
                                ),
                                controller: _reviewController,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final review = _reviewController.text.trim();
                                if (review.isNotEmpty) {
                                  final reviewerId = FirebaseAuth.instance.currentUser?.uid ?? '';
                                  final ratingValue = selectedRating.toInt();

                                  addReview(currentUser.uid, reviewerId, review, ratingValue);
                                  setState(() {
                                    _reviewController.clear();
                                    selectedRating = 0;
                                  });
                                }
                              },
                              child: Text('Post Review'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("Reviews")
                              .where('userId', isEqualTo: currentUser.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final reviewDocs = snapshot.data!.docs;
                              return Column(
                                children: reviewDocs.map((reviewDoc) {
                                  final reviewerUsername = reviewDoc['reviewerUsername'];
                                  final rating = reviewDoc['rating'];
                                  final comment = reviewDoc['comment'];
                                  final timestamp = reviewDoc['timestamp'].toDate();

                                  return ListTile(
                                    title: Text("Rating: $rating"),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Comment: $comment"),
                                        Text("By: $reviewerUsername"),
                                        Text("Date: $timestamp"),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                            return const Text("No reviews available.");
                          },
                        ),
                      ],
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

  Future<void> addReview(String userId, String reviewerId, String comment, int rating) async {
    final reviewsCollection = FirebaseFirestore.instance.collection("Reviews");
    final DateTime currentTime = DateTime.now();

    final reviewerDoc = await FirebaseFirestore.instance.collection("Users").doc(reviewerId).get();
    final String reviewerUsername = reviewerDoc['username'] as String;

    await reviewsCollection.add({
      'userId': userId,
      'reviewerId': reviewerId,
      'reviewerUsername': reviewerUsername,
      'rating': rating,
      'comment': comment,
      'timestamp': currentTime,
    });
  }
}

class Review {
  final int rating;
  final String comment;
  final String reviewerUsername;
  final DateTime timestamp;

  Review({
    required this.rating,
    required this.comment,
    required this.reviewerUsername,
    required this.timestamp,
  });
}
