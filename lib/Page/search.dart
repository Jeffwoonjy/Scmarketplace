  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:scmarketplace/Page/chat.dart';
  import 'package:scmarketplace/Page/viewVendor.dart';
  import 'package:scmarketplace/utills/colour.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:scmarketplace/Page/viewProfile.dart';

  class SearchUser extends StatefulWidget {
    const SearchUser({Key? key}) : super(key: key);

    @override
    State<SearchUser> createState() => _SearchUser();
  }

  class _SearchUser extends State<SearchUser> {
    Map<String, dynamic>? userMap;
    Map<String, dynamic>? vendorMap;
    bool isLoading = false;
    final TextEditingController _search = TextEditingController();

  String chatRoomId(String user1, String user2) {
    final List<String> sortedUserNames = [user1, user2]..sort();
    if (sortedUserNames[0] == sortedUserNames[1]) {
      throw Exception("Invalid user names: $user1, $user2");
    }
    return "${sortedUserNames[0]}${sortedUserNames[1]}";
  }

    void onSearch() async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      setState(() {
        isLoading = true;
      });

      String searchText = _search.text.trim();

      if (searchText.isEmpty) {
        print("Search text is empty");
        setState(() {
          isLoading = false;
          userMap = null;
          vendorMap = null;
        });
        return;
      }

        // Search in 'Users' collection
      QuerySnapshot usersQuery = await firestore
          .collection('Users')
          .where("username", isEqualTo: _search.text)
          .get();

      // Search in 'Vendors' collection
      QuerySnapshot vendorsQuery = await firestore
          .collection('vendors')
          .where("businessName", isEqualTo: _search.text)
          .get();

      print("Users Query Results: ${usersQuery.docs.length} documents");
      print("Vendors Query Results: ${vendorsQuery.docs.length} documents");

      setState(() {
      if (usersQuery.docs.isNotEmpty) {
        userMap = usersQuery.docs[0].data() as Map<String, dynamic>?;
        final String currentUserName =
            FirebaseAuth.instance.currentUser?.displayName ?? '';

        if (currentUserName == userMap?['username']) {
          userMap = null;
        }
      } else {
        userMap = null;
      }

      if (vendorsQuery.docs.isNotEmpty) {
        vendorMap = vendorsQuery.docs[0].data() as Map<String, dynamic>?;
      } else {
        vendorMap = null;
      }

      isLoading = false;
    });
  }

    @override
    Widget build(BuildContext context) {
      final size = MediaQuery.of(context).size;
      return Scaffold(
        appBar: AppBar(
          title: const Text("Search Page"),
          backgroundColor: const Color.fromARGB(255, 250, 98, 149),
        ),
        body: isLoading
            ? Center(
                child: SizedBox(
                  height: size.height / 20,
                  width: size.width / 20,
                  child: const CircularProgressIndicator(),
                ),
              )
            : StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.data != null) {
                      final String currentUserName = snapshot.data!.displayName ?? '';
                      return Column(
                        children: [
                          SizedBox(
                            height: size.height / 20,
                          ),
                          Container(
                            height: size.height / 14,
                            width: size.width,
                            alignment: Alignment.center,
                            child: SizedBox(
                              height: size.height / 14,
                              width: size.width / 1.15,
                              child: TextField(
                                controller: _search,
                                decoration: InputDecoration(
                                  hintText: "Search",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: size.height / 50,
                          ),
                          ElevatedButton(
                            onPressed: onSearch,
                            child: const Text("Search"),
                          ),
                          const SizedBox(height: 20),
                          userMap != null
                              ? ListTile(
                                  onTap: () {
                                    if (userMap != null && FirebaseAuth.instance.currentUser != null) {
                                      final String selectedUserId = userMap!['userId'] ?? '';
                                      
                                      print("Current User ID: '${FirebaseAuth.instance.currentUser!.uid}'");
                                      print("Selected User ID: '$selectedUserId'");

                                      if (selectedUserId.isNotEmpty) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ViewPage(
                                              userId: selectedUserId,
                                              userMap: userMap,
                                            ),
                                          ),
                                        );
                                      } else {
                                        print("Invalid user ID");
                                      }
                                    } else {
                                        print("userMap or FirebaseAuth.currentUser is null");
                                    }
                                  },
                                  leading: Icon(Icons.account_box, color: hexStringToColor("000000")),
                                  title: Text(
                                    userMap!['username'],
                                    style: TextStyle(
                                      color: hexStringToColor("000000"),
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Text(userMap!['email']),
                                  trailing: Icon(
                                    Icons.chat,
                                    color: hexStringToColor("000000"),
                                  ),
                                )
                                : Container(),  
                          if (vendorMap != null)
                          ListTile(
                            onTap: () {
                              if (vendorMap != null &&
                                  FirebaseAuth.instance.currentUser != null) {
                                final String selectedVendorId =
                                    vendorMap!['vendorId'] ?? '';

                                print("Current User ID: '${FirebaseAuth.instance.currentUser!.uid}'");
                                print("Selected Vendor ID: '$selectedVendorId'");

                                if (selectedVendorId.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VendorPage(
                                        vendorId: selectedVendorId,
                                        vendorMap: vendorMap,
                                      ),
                                    ),
                                  );
                                } else {
                                  print("Invalid vendor ID");
                                }
                              } else {
                                print(
                                    "vendorMap or FirebaseAuth.currentUser is null");
                              }
                            },
                            leading: Icon(
                              Icons.store,
                              color: hexStringToColor("000000"),
                            ),
                            title: Text(
                              vendorMap!['businessName'],
                              style: TextStyle(
                                color: hexStringToColor("000000"),
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(vendorMap!['email']),
                            trailing: Icon(
                              Icons.chat,
                              color: hexStringToColor("000000"),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  } else {
                    return Container();
                  }
                },
              ),
      );
    }
  }