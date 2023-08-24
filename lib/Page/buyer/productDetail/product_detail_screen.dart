import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scmarketplace/Page/provider/cart_provider.dart';

import '../../viewVendor.dart';

class ProductDetailScreen extends StatefulWidget {
  final DocumentSnapshot productData;

  const ProductDetailScreen({Key? key, required this.productData})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String formatedDate(date){
    final outPutDateFormate = DateFormat('dd/MM/yyyy');
    final outPutDate = outPutDateFormate.format(date);
    return outPutDate;
  }
  int _imageIndex = 0;
  String? _selectedSize;
  void showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CartProvider _cartProvider = Provider.of<CartProvider>(context);

    // Access the data from the DocumentSnapshot
    final Map<String, dynamic>? productData = widget.productData.data() as Map<String, dynamic>?;

    if (productData == null) {
      // Handle the case where data is null or invalid
      return Center(
        child: Text('Invalid data'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: const Color.fromARGB(255, 250, 98, 149),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          productData['productName'], // Access data from the Map
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 5,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  child: PhotoView(imageProvider: NetworkImage(productData['imageUrl'][_imageIndex])),
                ),

                Positioned(
                  bottom: 0,
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: productData['imageUrl'].length,
                      itemBuilder: (context, index){
                        return InkWell(
                          onTap: (){
                            setState(() {
                              _imageIndex = index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.yellow.shade900)
                              ),
                              height: 60,
                              width: 60,
                              child: Image.network(
                                  productData['imageUrl'][index]),
                            ),
                          ),
                        );
                      }),
                  ),),
              ],
            ),

            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(13.0),
              child: Text('RM' + '' + productData['productPrice'].toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink),
              ),
            ),

            Text(productData['productName'],
              style: TextStyle(
                fontSize: 22,
                letterSpacing: 8,

                fontWeight: FontWeight.bold,),
            ),

            ExpansionTile(title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text('Product Description', style: TextStyle(color: Colors.pink),),
                Text('View More', style: TextStyle(color: Colors.pink),
                ),
              ],
            ),

              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    productData['description'],
                    style: TextStyle(
                        fontSize: 17,color: Colors.grey,
                        letterSpacing: 2
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VendorPage(
                      vendorId: productData['vendorId'],
                      vendorMap: null,
                    ),
                  ),
                );
              },
              child: const Text(
                'Vendor Profile',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("This product will be ship on",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 250, 98, 149),
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                    ),
                  ),
                  Text(formatedDate(productData['scheduleDate'].toDate(),),
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            ExpansionTile(title: Text('Available Size',),
              children: [
                Container(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: productData['sizeList'].length,
                    itemBuilder: ((context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color:_selectedSize == productData['sizeList'][index]? Colors.yellow:null,
                          child: OutlinedButton(
                            onPressed: (){
                              setState(() {
                                _selectedSize = productData['sizeList'][index];
                              });

                              print(_selectedSize);
                            },
                            child: Text(
                                productData['sizeList'][index]), ),
                        ),
                      );
                    }),),
                )
              ],
            ),
          ],
        ),
      ),

      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: _cartProvider.getCartItem.containsKey(productData['productId'])? null:(){
            if(_selectedSize==null){
              return showSnack(context, 'Please Select A Size');
            }else{
              _cartProvider.addProductToCart(
                  productData['productName'],
                  productData['productId'],
                  productData['imageUrl'],
                  1,
                  productData['quantity'],
                  productData['productPrice'],
                  productData['vendorId'],
                  _selectedSize!,
                  productData['scheduleDate']);

              return showSnack(context, 'You Have Added ${productData['productName']} To Your Cart');
            }
          },
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: _cartProvider.getCartItem.containsKey(widget.productData['productId'])
              ?Colors.grey 
              :const Color.fromARGB(255, 250, 98, 149),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      CupertinoIcons.cart,
                      color: Colors.white, size: 18,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _cartProvider.getCartItem.containsKey(productData['productId'])? Text('In Cart',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 5,
                      ),
                    ):Text('Add To Cart',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 5,
                      ),),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
