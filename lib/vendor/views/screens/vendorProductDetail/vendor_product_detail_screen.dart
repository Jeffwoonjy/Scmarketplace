import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../utills/colour.dart';

class VendorProductDetailScreen extends StatefulWidget {
  final dynamic productData;

  const VendorProductDetailScreen({super.key, required this.productData});

  @override
  State<VendorProductDetailScreen> createState() =>
      _VendorProductDetailScreenState();
}

class _VendorProductDetailScreenState
    extends State<VendorProductDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _productNameController =
      TextEditingController();
  final TextEditingController _brandNameController =
      TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController();
  final TextEditingController _productPriceController =
      TextEditingController();
  final TextEditingController _productDescriptionController =
      TextEditingController();
  final TextEditingController _categoryNameController =
      TextEditingController();

  @override
  void initState() {
    setState(() {
      _productNameController.text = widget.productData['productName'];
      _brandNameController.text = widget.productData['brandName'];
      _productPriceController.text =
          widget.productData['productPrice'].toString();
      _quantityController.text = widget.productData['quantity'].toString();
      _productDescriptionController.text = widget.productData['description'];
      _categoryNameController.text = widget.productData['category'];
    });
    super.initState();
  }

  double? productPrice;
  int? productQuantity;

  void showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hexStringToColor("FFC0CB"),
        elevation: 0,
        title: Text(
          widget.productData['productName'],
          style: TextStyle(
              color: Colors.white,
              letterSpacing: 4,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: _productNameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            SizedBox(height: 20,),
            TextFormField(
              controller: _brandNameController,
              decoration: InputDecoration(labelText: 'Brand Name'),
            ),
            SizedBox(height: 20,),
            TextFormField(
              onChanged: (value){
                productQuantity = int.parse(value);
              },
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
            ),
            SizedBox(height: 20,),
            TextFormField(
              onChanged: (value){
                productPrice = double.parse(value);
              },
              controller: _productPriceController,
              decoration: InputDecoration(labelText: 'Product Price'),
            ),
            SizedBox(height: 20,),
            TextFormField(
              maxLength: 800,
              maxLines: 3,
              controller: _productDescriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20,),
            TextFormField(
              enabled: false,
              controller: _categoryNameController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(12.0),
        child: InkWell(
          onTap: () async {
            if (productPrice != null && productQuantity != null) {
              await _firestore.collection('products')
                  .doc(widget.productData['productId'])
                  .update({
                'productName': _productNameController.text,
                'brandName': _brandNameController.text,
                'quantity': productQuantity,
                'productPrice': productPrice,
                'description': _productDescriptionController.text,
                'category': _categoryNameController.text,
              });
            } else {
              showSnack(context, 'Update Quantity And Price');
            }
          },
          child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: hexStringToColor("FFC0CB"),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Update Product',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
