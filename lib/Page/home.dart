import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scmarketplace/Page/signIn.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
    body: Center(
      child: ElevatedButton(
        child: const Text("Logout"),
        onPressed: () {
          FirebaseAuth.instance.signOut().then((value){
            print("Signout");
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignIn()));
          });
        },
      ),
    ),
    );
  }
}