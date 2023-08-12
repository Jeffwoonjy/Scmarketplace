import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scmarketplace/Page/chat.dart';
import 'package:scmarketplace/Page/viewProfile.dart';

class AllChat extends StatefulWidget {
  const AllChat({Key? key}) : super(key: key);

  @override
  State<AllChat> createState() => _AllChatState();
}

class _AllChatState extends State<AllChat> {
  late User? currentUser;
  List<String> chatroomIds = [];

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    fetchChatroomIds();
  }

  Future<void> fetchChatroomIds() async {
    try {
      final chatroomSnapshot = await FirebaseFirestore.instance
          .collection('chatroom')
          .where('users', arrayContains: currentUser?.uid)
          .get();

      final userChatroomIds = chatroomSnapshot.docs.map((doc) {
        final users = doc['users'] as List<dynamic>;
        final selectedUserId = users.firstWhere(
          (userId) => userId != currentUser?.uid,
          orElse: () => null,
        );
        if (selectedUserId != null) {
          return "$selectedUserId${currentUser!.uid}";
        }
        return null;
      }).whereType<String>().toList();

      setState(() {
        chatroomIds = userChatroomIds;
      });
      print("Fetched Chatroom IDs: $chatroomIds");  
    } catch (error) {
      print("Error fetching chatroom IDs: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Chats"),
      ),
      body: chatroomIds.isEmpty
          ? const Center(
              child: Text("No chats available"),
            )
          : ListView.builder(
              itemCount: chatroomIds.length,
              itemBuilder: (context, index) {
                final roomId = chatroomIds[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoom(
                          chatRoomId: roomId,
                          userMap: null, // Pass appropriate userMap if needed
                        ),
                      ),
                    );
                  },
                  title: Text("Chatroom: $roomId"),
                );
              },
            ),
    );
  }
}


