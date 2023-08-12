import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scmarketplace/Page/buyer/inner_screens/checkout_screen.dart';
import 'package:scmarketplace/provider/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartProvider _cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        elevation: 0,
        title: Text(
          'Cart',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 4, color: Colors.white),
        ),

        actions: [
          IconButton(onPressed: (){
            _cartProvider.removeAllItem();
          }, icon: Icon(CupertinoIcons.delete, color: Colors.white,))
        ],
      ),
      body: _cartProvider.getCartItem.isNotEmpty ? ListView.builder(
        shrinkWrap: true,
        itemCount: _cartProvider.getCartItem.length,
        itemBuilder: (context, index) {
          final cartData = _cartProvider.getCartItem.values.toList()[index];
          return Card(
            child: ListTile(
              leading: Image.network(cartData.imageUrl[0]),
              title: Text(
                cartData.productName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 4),
              ),
              subtitle: Column(
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
                  Row(
                    children: [
                      Container(
                        height: 34,
                        width: 115,
                        decoration: BoxDecoration(color: Colors.pink),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: cartData.quantity == 1
                                  ? null
                                  : () {
                                      _cartProvider.decreaMent(cartData);
                                    },
                              icon: Icon(CupertinoIcons.minus, color: Colors.white),
                            ),
                            Text(
                              cartData.quantity.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                            IconButton(
                              onPressed: cartData.productQuantity == cartData.quantity
                                  ? null
                                  : () {
                                      _cartProvider.increament(cartData);
                                    },
                              icon: Icon(CupertinoIcons.plus, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _cartProvider.removeItem(cartData.productId);
                        },
                        icon: Icon(CupertinoIcons.cart_badge_minus),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ):

      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Shopping Cart Is Empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width -40,
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Continue Shopping',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),),

      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: _cartProvider.totalPrice == 0.00? null:(){
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return CheckoutScreen();
            }));
          },
          child: Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _cartProvider.totalPrice == 0.00? Colors.grey:  Colors.pink,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "RM" + _cartProvider.totalPrice.toStringAsFixed(2) + " " + 'Checkout',
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 8,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
