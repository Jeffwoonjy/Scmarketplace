import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scmarketplace/Page/viewProfile.dart';
import 'package:scmarketplace/Page/viewVendor.dart';

class ChatRoom extends StatelessWidget {
  final String chatRoomId;
  final String currentUserId;
  final String receiverID;
  final bool isVendor;
  final String? vendorBusinessName;
  final String? chatTitle;
  final Map<String, dynamic>? userMap;

  ChatRoom({
    required this.chatRoomId,
    this.userMap,
    required this.currentUserId,
    required this.receiverID,
    this.vendorBusinessName,
    required this.isVendor,
    this.chatTitle,
    Key? key, required String userID,
  }) : super(key: key);

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      print("receiverID: $receiverID");
      print("userID: $currentUserId");
      Map<String, dynamic> message = {
        "sendby": currentUserId,
        "message": _message.text,
        "time": FieldValue.serverTimestamp(),
        "receiverID": receiverID,
        "userID": currentUserId,
      };

      Map<String, dynamic> chatRoomData = {
        "receiverID": receiverID,
        "userID": currentUserId,
      };

      _message.clear();
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(message);

      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .set(chatRoomData, SetOptions(merge: true));

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      print("Enter Some Text");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(chatTitle ?? 'Chat'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.25,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chatroom')
                    .doc(chatRoomId)
                    .collection('chats')
                    .orderBy("time", descending: false)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final message = snapshot.data!.docs[index]['message'];
                        final sendBy = snapshot.data!.docs[index]['sendby'];

                        final isSentByCurrentUser = sendBy == currentUserId;

                        return ListTile(
                          title: Align(
                            alignment: isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSentByCurrentUser ? Colors.pink : Colors.pink,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                message,
                                style: TextStyle(
                                  color: isSentByCurrentUser ? Colors.white : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: SizedBox(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  children: [
                    SizedBox(
                      height: size.height / 12,
                      width: size.width / 1.3,
                      child: TextField(
                        controller: _message,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.send), onPressed: onSendMessage),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}