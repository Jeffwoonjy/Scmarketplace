import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scmarketplace/Page/chat.dart';
import 'package:scmarketplace/Page/search.dart';

import '../utills/colour.dart';

class AllChatScreen extends StatefulWidget {
  final Map<String, dynamic>? userMap;

  const AllChatScreen({Key? key, this.userMap}) : super(key: key);

  @override
  _AllChatScreenState createState() => _AllChatScreenState();
}

class _AllChatScreenState extends State<AllChatScreen> {
  late User? currentUser;
  late List<DocumentSnapshot> chatRooms;
  Map<String, String> chatUsernames = {};

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    chatRooms = [];
    fetchChatRooms();
  }

  Future<void> fetchChatRooms() async {
    try {
      final String? currentUserID = currentUser?.uid;
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('chatroom').get();

      snapshot.docs.forEach((doc) async {
        final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        print("Document data: $data");
        if (data != null) {
          final String? userID = data['userID'] as String?;
          final String? receiverID = data['receiverID'] as String?;
          print("userID: $userID, receiverID: $receiverID");

          if (userID != null && receiverID != null) {
            if (currentUserID == userID || currentUserID == receiverID) {
              final String combinedID = "$userID$receiverID";
              final String reverseCombinedID = "$receiverID$userID";
              if (combinedID == doc.id) {
                fetchData(combinedID, receiverID, userID);
              }
              if (reverseCombinedID == doc.id) {
                fetchData(reverseCombinedID, receiverID, userID);
              }
              final usernameSnapshot = await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(userID)
                  .get();
              final username = usernameSnapshot['username'] as String?;

              final isVendorChatRoom = await checkIfVendorChatRoom(receiverID);

              String displayUsername = '';
              if (isVendorChatRoom) {
                final vendorName =
                    await getVendorBusinessName(receiverID);
                displayUsername = vendorName ?? 'Vendor';
              } else {
                displayUsername = username ?? 'Unknown User';
              }

              if (displayUsername.isNotEmpty) {
                setState(() {
                  chatUsernames[doc.id] = displayUsername;
                });
              }
            }
          }
        }
      });

      print("Fetched Chat Rooms");
    } catch (error) {
      print("Error fetching chat rooms: $error");
    }
  }

  Future<void> fetchData(String id, String receiverID, String userID) async {
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('chatroom')
          .doc(id)
          .get();

      setState(() {
        chatRooms.add(snapshot);
      });
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  Future<bool> checkIfVendorChatRoom(String userID) async {
    final vendorsSnapshot = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(userID)
        .get();
    return vendorsSnapshot.exists;
  }

  Future<String?> getVendorBusinessName(String userID) async {
    final vendorsSnapshot = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(userID)
        .get();
    return vendorsSnapshot['businessName'] as String?;
  }

  String? selectedChatRoomId;
  String? selectedReceiverId;
  String? selectedUserId;

  void navigateToChatRoom(String chatRoomId, String receiverId, String userID, String displayUsername) {
    setState(() {
      selectedChatRoomId = chatRoomId;
      selectedReceiverId = receiverId;
      selectedUserId = userID;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoom(
          chatRoomId: chatRoomId,
          currentUserId: currentUser!.uid,
          userMap: widget.userMap,
          receiverID: receiverId,
          userID: userID,
          isVendor: true,
          chatTitle: displayUsername,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Chats"),
        backgroundColor: hexStringToColor("FFC0CB"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchUser()),
              );
            },
          ),
        ],
      ),
      body: chatRooms.isEmpty
          ? const Center(
              child: Text("No chat rooms available"),
            )
          : ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoomId = chatRooms[index].id;
                final receiverId = chatRooms[index]['receiverID'] as String;
                final userID = chatRooms[index]['userID'] as String;
                final username = chatUsernames[chatRoomId] ?? 'Unknown User';
                return ListTile(
                  onTap: () {
                    navigateToChatRoom(chatRoomId, receiverId, userID, username);
                  },
                  title: Text(" $username"),
                );
              },
            ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: AllChatScreen(),
  ));
}
