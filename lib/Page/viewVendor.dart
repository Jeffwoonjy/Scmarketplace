import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scmarketplace/utills/colour.dart';
import 'package:scmarketplace/Page/chat.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../utills/text_box.dart';

class VendorPage extends StatefulWidget {
  final String vendorId;
  final Map<String, dynamic>? vendorMap;

  const VendorPage({Key? key, required this.vendorId, required this.vendorMap})
      : super(key: key);

  @override
  State<VendorPage> createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> {
double selectedRating = 0;
  String chatRoomId(String user1, String user2) {
    final List<String> sortedUserNames = [user1, user2]..sort();
    if (sortedUserNames[0] == sortedUserNames[1]) {
      throw Exception("Invalid user names: $user1, $user2");
    }
    return "${sortedUserNames[0]}${sortedUserNames[1]}";
  }

  final TextEditingController _reviewController = TextEditingController();

  Future<void> addReview(String vendorId, String reviewerId, String comment, int rating) async {
    final reviewsCollection = FirebaseFirestore.instance.collection("Reviews");

    final DateTime currentTime = DateTime.now();

    await reviewsCollection.add({
      'vendorId': vendorId,
      'reviewerId': reviewerId,
      'rating': rating,
      'comment': comment,
      'timestamp': currentTime,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vendorMap?['businessName'] ?? 'Vendor Profile',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 5,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 250, 98, 149),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("vendors").doc(widget.vendorId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error ${snapshot.error}"),
            );
          } else if (snapshot.hasData && snapshot.data!.exists) {
            final userData = snapshot.data!.data();
            if (userData != null && userData is Map<String, dynamic>) {
              return ListView(
                children: [
                  const SizedBox(height: 50),
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white,
                    backgroundImage: userData['storeImage'] != null
                        ? NetworkImage(userData['storeImage'])
                        : null,
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      "Vendor details",
                      style: TextStyle(color: hexStringToColor("F1C40F")),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
                      final String receiverID= widget.vendorId;

                      if (currentUserId.isNotEmpty && receiverID.isNotEmpty) {
                        final String roomId = chatRoomId(currentUserId, receiverID);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatRoom(
                              chatRoomId: roomId,
                              userMap: widget.vendorMap,
                              currentUserId: currentUserId, 
                              receiverID: receiverID,
                              userID: currentUserId,
                              vendorBusinessName: widget.vendorMap?['businessName'],
                              isVendor: true,
                            ),
                          ),
                        );
                      } else {
                        print("Invalid user IDs");
                      }
                    },
                    child: const Text("Chat"),
                  ),
                  MyTextBox(
                    text: userData['businessName'],
                    sectionName: 'BusinessName',
                  ),
                  //email
                  MyTextBox(
                    text: userData['email'],
                    sectionName: 'email',
                  ),
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
                          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
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

                                  addReview(widget.vendorId, reviewerId, review, ratingValue);
                                  setState(() {
                                    _reviewController.clear();
                                    selectedRating = 0;
                                  });
                                }
                              },
                              child: const Text('Post Review'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("Reviews")
                              .where('vendorId', isEqualTo: widget.vendorId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final reviewDocs = snapshot.data!.docs;
                              return Column(
                                children: reviewDocs.map((reviewDoc) {
                                  final reviewerId = reviewDoc['reviewerId'];
                                  final rating = reviewDoc['rating'];
                                  final comment = reviewDoc['comment'];
                                  final timestamp = reviewDoc['timestamp'].toDate();

                                  return ListTile(
                                    title: Text("Rating: $rating"),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Comment: $comment"),
                                        Text("By: $reviewerId"),
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
                  // User posts section here
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

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const _InfoCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Card(
        color: hexStringToColor("000000"), // Replace with appropriate color
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(color: hexStringToColor("F1C40F")), // Replace with appropriate color
          ),
          subtitle: Text(
            content,
            style: TextStyle(color: hexStringToColor("ffffff")), // Replace with appropriate color
          ),
        ),
      ),
    );
  }
}
