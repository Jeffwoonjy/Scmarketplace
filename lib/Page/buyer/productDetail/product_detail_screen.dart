import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scmarketplace/Page/provider/cart_provider.dart';
import 'package:scmarketplace/Page/viewVendor.dart';


class ProductDetailScreen extends StatefulWidget {
  final dynamic productData;

  const ProductDetailScreen({super.key, required this.productData});

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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.pink,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.productData['productName'], 
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
                  child: PhotoView(imageProvider: NetworkImage(widget.productData['imageUrl'][_imageIndex])),
                ),
      
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.productData['imageUrl'].length,
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
                              widget.productData['imageUrl'][index]),
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
               child: Text('RM' + '' + widget.productData['productPrice'].toStringAsFixed(2),
                style: TextStyle(
                fontSize: 22,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
                color: Colors.pink),
                ),
             ),
      
              Text(widget.productData['productName'],
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
                    widget.productData['description'],
                  style: TextStyle(
                    fontSize: 17,color: Colors.grey,
                    letterSpacing: 2 
                    ),
                    textAlign: TextAlign.center,
                    ),
                ),
              ],
              ),

              ExpansionTile(title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Vendor Profiel', style: TextStyle(color: Colors.pink),),
                  Text('View More', style: TextStyle(color: Colors.pink),
                  ),
                ],
              ),
              
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Vendor Profiel',
                  style: TextStyle(
                    fontSize: 17,color: Colors.grey,
                    letterSpacing: 2 
                    ),
                    textAlign: TextAlign.center,
                    ),
                ),
              ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("This product will be ship on", 
                    style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                      ),
                      ),
                      Text(formatedDate(widget.productData['scheduleDate'].toDate(),),
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
                    itemCount: widget.productData['sizeList'].length,
                    itemBuilder: ((context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color:_selectedSize == widget.productData['sizeList'][index]? Colors.yellow:null,
                          child: OutlinedButton(
                            onPressed: (){
                              setState(() {
                                _selectedSize = widget.productData['sizeList'][index];
                              });
                        
                              print(_selectedSize);
                            }, 
                            child: Text(
                              widget.productData['sizeList'][index]), ),
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
          onTap: _cartProvider.getCartItem.containsKey(widget.productData['productId'])? null:(){
            if(_selectedSize==null){
              return showSnack(context, 'Please Select A Size');
            }else{
              _cartProvider.addProductToCart(
              widget.productData['productName'], 
              widget.productData['productId'], 
              widget.productData['imageUrl'], 
              1,
              widget.productData['quantity'],
              widget.productData['productPrice'], 
              widget.productData['vendorId'], 
              _selectedSize!, 
              widget.productData['scheduleDate']);

              return showSnack(context, 'You Have Added ${widget.productData['productName']} To Your Cart');
            }
          },
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: _cartProvider.getCartItem.containsKey(widget.productData['productId'])
              ?Colors.grey 
              :Colors.pink,
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
                  child: _cartProvider.getCartItem.containsKey(widget.productData['productId'])? Text('In Cart', 
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