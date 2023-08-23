import 'package:flutter/material.dart';
import 'package:scmarketplace/vendor/views/screens/edit_products_tabs/published_tab.dart';
import 'package:scmarketplace/vendor/views/screens/edit_products_tabs/unpublished_tab.dart';

import '../../../utills/colour.dart';

class EditProductScreen extends StatelessWidget {
  const EditProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2, child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 3,
        backgroundColor: Color.fromARGB(255, 250, 98, 149),
        title: Text('Manage Products', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold, 
          color: Colors.white,
          letterSpacing: 3),
          ),

          bottom: TabBar(tabs: [
            Tab(child: Text('Published', style: TextStyle(color: Colors.white),),), 
            Tab(child: Text('Unpublished', style: TextStyle(color: Colors.white)),),
          ]),
          ),

          body: TabBarView(children: [
            PublishedTab(),
            UnPublishedTab(),
          ]),
    ),
    );
  }
}