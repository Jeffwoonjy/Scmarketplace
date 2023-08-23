import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scmarketplace/Page/buyer/nav_screens/category_screen.dart';
import 'package:scmarketplace/Page/buyer/nav_screens/widgets/home_products.dart';
import 'package:scmarketplace/Page/buyer/nav_screens/widgets/main_products_widget.dart';

class CategoryText extends StatefulWidget {
  @override
  State<CategoryText> createState() => _CategoryTextState();
}

class _CategoryTextState extends State<CategoryText> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _categoryStream = FirebaseFirestore.instance.collection('Categories').snapshots();
    return Padding(
      padding: const EdgeInsets.all(9.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: TextStyle(fontSize: 19),
          ),

          StreamBuilder<QuerySnapshot>(
            stream: _categoryStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Loading Categories"),
                );
              }

              return Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final categoryData = snapshot.data!.docs[index];
                    return Container(
                      margin: EdgeInsets.all(8.0),
                      child: ActionChip(
                        backgroundColor: const Color.fromARGB(255, 250, 98, 149),
                        onPressed: () {
                          setState(() {
                            _selectedCategory = categoryData['categoryName'];
                          });
                          print(_selectedCategory);
                        },
                        label: Center(
                          child: Text(
                            categoryData['categoryName'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          if (_selectedCategory == null) MainProductsWidget(),
          if (_selectedCategory != null) HomeproductWidget(categoryName: _selectedCategory!),
        ],
      ),
    );
  }
}
