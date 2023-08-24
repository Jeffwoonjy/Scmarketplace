import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scmarketplace/utills/colour.dart';
import 'package:scmarketplace/Page/chat.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../utills/text_box.dart';

class ViewPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? userMap;

  const ViewPage({Key? key, required this.userId, required this.userMap}) : super(key: key);

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  double selectedRating = 0;
  String chatRoomId(String user1, String user2) {
    final List<String> sortedUserNames = [user1, user2]..sort();
    if (sortedUserNames[0] == sortedUserNames[1]) {
      throw Exception("Invalid user names: $user1, $user2");
    }
    return "${sortedUserNames[0]}${sortedUserNames[1]}";
  }

  final TextEditingController _reviewController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text(
          widget.userMap?['username'] ?? 'User Profile',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 5,
          ),
        ),
        backgroundColor: hexStringToColor("FFC0CB"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").doc(widget.userId).snapshots(),
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
                    backgroundImage: userData['profilePicture'] != null
                        ? NetworkImage(userData['profilePicture'])
                        : null,
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      "User details",
                      style: TextStyle(color: hexStringToColor("F1C40F")),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
                      final String receiverId= widget.userId;

                      if (currentUserId.isNotEmpty && receiverId.isNotEmpty) {
                        final String roomId = chatRoomId(currentUserId, receiverId);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatRoom(
                              chatRoomId: roomId,
                              userMap: widget.userMap,
                              currentUserId: currentUserId, 
                              receiverID: receiverId,
                              userID: currentUserId,
                              isVendor: false,
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
                    text: userData['username'],
                    sectionName: 'username',
                  ),
                  //email
                  MyTextBox(
                    text: userData['email'],
                    sectionName: 'email',
                  ),
                  //address
                  MyTextBox(
                    text: userData['address'],
                    sectionName: 'address',
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

                                  addReview(widget.userId, reviewerId, review, ratingValue);
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
                              .where('userId', isEqualTo: widget.userId)
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
        color: hexStringToColor("000000"),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(color: hexStringToColor("F1C40F")),
          ),
          subtitle: Text(
            content,
            style: TextStyle(color: hexStringToColor("ffffff")),
          ),
        ),
      ),
    );
  }
}