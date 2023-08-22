import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scmarketplace/vendor/views/screens/vendor_inner_screen/withdrawal_screen.dart';

import '../../../utills/colour.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('vendors');
    final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance
    .collection('orders').where('vendor',isEqualTo: FirebaseAuth.instance.currentUser!.uid)
    .snapshots();
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
              backgroundColor: hexStringToColor("FFC0CB"),
              elevation: 2,
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(data['storeImage']),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Hi ' + data['businessName'],style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 6,
                        ),),
                    ),
                ]),
            ),

            body: StreamBuilder<QuerySnapshot>(
      stream: _ordersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        double totalOrder = 0.0;
        for(var orderItem in snapshot.data!.docs){
          totalOrder += orderItem['quantity'] * orderItem['productPrice'];
        }

        return Center(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 150,
                      width: MediaQuery.of(context).size.width * 0.5,
                      decoration: BoxDecoration(
                        color: hexStringToColor("FFC0CB"),
                        borderRadius: BorderRadius.circular(32),
                      ),
              
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Total Earning', style: TextStyle(
                              color: Colors.white, 
                              fontSize: 22,
                              fontWeight: FontWeight.bold,),
                              ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(          
                            'RM' + '' + totalOrder.toStringAsFixed(2), 
                            style: TextStyle(
                              color: Colors.black, 
                              letterSpacing: 4,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,),
                              ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 150,
                      width: MediaQuery.of(context).size.width * 0.5,
                      decoration: BoxDecoration(
                        color: hexStringToColor("FFC0CB"),
                        borderRadius: BorderRadius.circular(32),
                      ),
              
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Total Orders', style: TextStyle(
                              color: Colors.white, 
                              fontSize: 22,
                              fontWeight: FontWeight.bold,),
                              ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(          
                            snapshot.data!.docs.length.toString(), 
                            style: TextStyle(
                              color: Colors.black, 
                              letterSpacing: 4,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,),
                              ),
                          ),
                        ],
                      ),
                    ),

                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return WithdrawalScreen();
                        }));
                      },
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width - 40,
                        decoration: BoxDecoration(
                          color: hexStringToColor("FFC0CB"), 
                          borderRadius: BorderRadius.circular(10),
                          ),
                    
                          child: Center(
                            child: Text('Withdraw',style: TextStyle(
                              color: Colors.white, fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),),),
                      ),
                    ),
                    

                  ]),
              ),
            );
      },
    )
          );
        }

        return Center(
          child: CircularProgressIndicator(color: hexStringToColor("FFC0CB")),
        );
      },
    );
  }
}