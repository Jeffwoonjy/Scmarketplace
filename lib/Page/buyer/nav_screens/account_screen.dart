import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scmarketplace/Page/buyer/inner_screens/order_screen.dart';
import 'package:scmarketplace/Page/signIn.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(FirebaseAuth.instance.currentUser!.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        elevation: 0,
        title: Text('Profile', style: TextStyle(letterSpacing: 4, color: Colors.white),),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Icon(Icons.star),
          ),
        ],
      ),

      body: Column(
        children: [

          SizedBox(height: 25,),
        Center(child: CircleAvatar(radius: 64, backgroundColor: Colors.pink,
        backgroundImage: NetworkImage(data['profilePicture']),
        ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            data['username'],
            style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,
          ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            data['email'],
            style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,
          ),
          ),
        ),

        Container(
          height: 40,
          width: MediaQuery.of(context).size.width -200,
          decoration: BoxDecoration(
            color: Colors.pink,
            borderRadius: BorderRadius.circular(10)
          ),

          child: Center(child: Text('Edit Profile', 
          style: TextStyle(
            color: Colors.white,letterSpacing: 6,),)),
        ),

        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Divider(thickness: 2, color: Colors.grey,),
        ),

        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
        ),

        ListTile(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return CustomerOrderScreen();
            }));
          },
          leading: Icon(CupertinoIcons.shopping_cart),
          title: Text('Order'),
        ),

        ListTile(
          onTap: ()async{
            Navigator.push(context,
            MaterialPageRoute(builder: (context){
              return SignIn();
            }));
          },
          leading: Icon(Icons.logout),
          title: Text('Logout'),
        ),
      ],
      ),
    );
        }

        return CircularProgressIndicator();
      },
    );
    
    
  }
}