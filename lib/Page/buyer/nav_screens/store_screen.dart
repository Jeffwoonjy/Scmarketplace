import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scmarketplace/Page/buyer/productDetail/store_detail_screen.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _vendorsStream = FirebaseFirestore.instance.collection('vendors').snapshots();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 250, 98, 149),
        elevation: 3,
        title: Text('Store',
        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 4, color: Colors.white),), // Add the 'Store' title to the AppBar
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _vendorsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.grey),);
          }

          return Container(
            height: 500,
            child: ListView.builder(
              itemCount: snapshot.data!.size,
              itemBuilder: (context, index){
                final storeData = snapshot.data!.docs[index];
                return GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return StoreDetailScreen(storeData: storeData,);
                    }));
                  },
                  child: ListTile(
                    title: Text(storeData['businessName']),
                    subtitle: Text(storeData['countryValue']),
                
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(storeData['storeImage']),
                    ),
                  ),
                );
              }),
          );
        },
      ),
    );
  }
}
