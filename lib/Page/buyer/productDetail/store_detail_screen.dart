import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scmarketplace/Page/buyer/productDetail/product_detail_screen.dart';

class StoreDetailScreen extends StatelessWidget {
  final dynamic storeData;

  const StoreDetailScreen({super.key, required this.storeData});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _productsStream = FirebaseFirestore.instance
    .collection('products').where('vendorId',isEqualTo: storeData['vendorId'])
    .snapshots();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 250, 98, 149),
        title: Text(
          storeData['businessName'],style: TextStyle(color: Colors.white),),
          ),

          body: StreamBuilder<QuerySnapshot>(
      stream: _productsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(color: Colors.grey),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        if(snapshot.data!.docs.isEmpty){
          return Center(
            child: Text('No Products Uploaded',style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold
            ),),
          );
        }

        return GridView.builder(
          itemCount: snapshot.data!.size,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 200/300,
        ), itemBuilder: (context, index){
          final productData = snapshot.data!.docs[index];
              return GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return ProductDetailScreen(productData: productData,);
                  }));
                },
                child: Card(
                  child: Column(
                    children: [
                      Container(
                        height: 170,
                        width: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              productData['imageUrl'][0],
                              ),
                              fit: BoxFit.cover,
                              ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(productData['productName'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 4,
                        ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'RM' + " " +
                          productData['productPrice'].toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 4,
                          color: Colors.red.shade900,
                        ),
                        ),
                      ),
                  ]),
                ),
              );
        }); 
      },
    ),
    );
  }
}