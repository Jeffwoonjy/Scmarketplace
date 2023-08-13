import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:scmarketplace/Page/buyer/main_screen.dart';
import 'package:scmarketplace/Page/provider/cart_provider.dart';
import 'package:uuid/uuid.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final CartProvider _cartProvider = Provider.of<CartProvider>(context);
    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(FirebaseAuth.instance.currentUser!.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Center(child: Text("Document does not exist"));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.pink,
        title: Text('Checkout',style: TextStyle(fontSize: 18,letterSpacing: 6, fontWeight: FontWeight.bold),),
      ),

      body: ListView.builder(
        shrinkWrap: true,
        itemCount: _cartProvider.getCartItem.length,
        itemBuilder: (context, index) {
          final cartData = _cartProvider.getCartItem.values.toList()[index];
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              child: ListTile(
                leading: Image.network(cartData.imageUrl[0]),
                title: Text(
                  cartData.productName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 4),
                ),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RM' + "" + cartData.price.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        color: Colors.pink,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: null,
                      child: Text(cartData.productSize),
                    ),
                    
                  ],
                ),
              ),
            ),
          );
        },
      ),

      bottomSheet: data['address'] == ''
      ? TextButton(onPressed: (){}, child: Text('Enter Billing Address')):
      Padding(
        padding: const EdgeInsets.all(13.0),
        child: InkWell(
          onTap: (){
            EasyLoading.show(status: 'Placing Order');
            _cartProvider.getCartItem.forEach((key, item) {
              final orderId = Uuid().v4();
              _firestore.collection('orders').doc(orderId).set({
                'orderId':orderId,
                'vendor':item.vendorId,
                'userId': data['userId'],
                'email': data['email'],
                'username': data['username'],
                'address':data['address'],
                'productName':item.productName,
                'productPrice':item.price,
                'productId':item.productId,
                'productImage':item.imageUrl,
                'quantity':item.productQuantity,
                'productSize':item.productSize,
                'scheduleDate':item.scheduleDate, 
                'orderDate':DateTime.now(),
                'accepted': false,

              }).whenComplete((){
                setState(() {
                  _cartProvider.getCartItem.clear();
                });

                EasyLoading.dismiss();

                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                  return MainScreen();
                }));
              });
            });
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(10)
            ),
            height: 50,
            child: Center(child: Text('PLACE ORDER', style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold,),)),
            ),
        ),
      ),
    );
        }

        return Center (
          child: CircularProgressIndicator(color: Colors.pink,),
        );
      },
    );

    
  }
}