import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerOrderScreen extends StatelessWidget {
  String formatedDate(date){
    final outPutDateFormate = DateFormat('dd/MM/yyyy');
    final outPutDate = outPutDateFormate.format(date);
    return outPutDate;
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance
    .collection('orders').where('userId',isEqualTo: FirebaseAuth.instance.currentUser!.uid)
    .snapshots();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        elevation: 0,
        title: Text('My Orders', 
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 4),
        ),
        ),

        body:  StreamBuilder<QuerySnapshot>(
      stream: _ordersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.pink),);
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {

            return Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 14,
                    child: document['accepted'] == true? Icon(Icons.delivery_dining):Icon(Icons.access_time),
                  ),

                  title: document['accepted'] == true
                  ?Text('Accepted', style: TextStyle(color: Colors.blue),)
                  :Text('Not Accepted', style: TextStyle(color: Colors.red),),

                  trailing: Text('Amount' + ' ' + document['productPrice'].toStringAsFixed(2), 
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey
                  ),),

                  subtitle: Text(formatedDate(document['orderDate'].toDate(),),style: 
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey
                  ),),
                ),

                ExpansionTile(title: Text('Order Details', 
                style: TextStyle(
                  color: Colors.yellow.shade900,
                  fontSize: 15),
                  ),

                  subtitle: Text('View Order Details'),

                  children: [
                    ListTile(
                      leading: CircleAvatar(child: Image.network(document['productImage'][0],),
                      ),

                      title: Text(document['productName'],style: TextStyle(fontWeight: FontWeight.bold),),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(('Quantity'),style: TextStyle(fontSize: 14,),),

                              Text(document['quantity'].toString(),),
                            ],
                          ),

                          document['accepted'] == true? 
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                            Text('Schedule Delivery Date'),
                            Text(formatedDate(document['scheduleDate'].toDate()))
                          ],):Text(''),

                          ListTile(title: Text('Buyer Details', style: TextStyle(
                            fontSize: 18,
                          ),
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(document['username']),
                              Text(document['email']),
                              Text(document['address']),
                            ],
                          ),
                          ),
                        ]
                        ),
                    )
                  ],
                  ),
              ],
            );
          
          }).toList(),
        );
      },
    ),
    );
  }
}