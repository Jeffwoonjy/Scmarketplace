import 'package:flutter/material.dart';
import 'package:scmarketplace/vendor/views/screens/edit_products_tabs/published_tab.dart';
import 'package:scmarketplace/vendor/views/screens/edit_products_tabs/unpublished_tab.dart';

class EditProductScreen extends StatelessWidget {
  const EditProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2, child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.pink,
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