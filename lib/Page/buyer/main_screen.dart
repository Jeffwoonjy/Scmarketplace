import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scmarketplace/Page/allChat.dart';
import 'package:scmarketplace/Page/buyer/nav_screens/account_screen.dart';
import 'package:scmarketplace/Page/buyer/nav_screens/cart_screen.dart';
import 'package:scmarketplace/Page/buyer/nav_screens/category_screen.dart';
import 'package:scmarketplace/Page/buyer/nav_screens/home_screen.dart';
import 'package:scmarketplace/Page/buyer/nav_screens/search_screen.dart';
import 'package:scmarketplace/Page/buyer/nav_screens/store_screen.dart';
import 'package:scmarketplace/Page/chat.dart';
import 'package:scmarketplace/Page/profile.dart';
import 'package:scmarketplace/Page/search.dart';
import 'package:scmarketplace/Page/viewProfile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;

  List<Widget> _pages = [
    HomeScreen(),
    CategoryScreen(),
    StoreScreen(),
    CartScreen(),
    SearchScreen(),
    AllChatScreen(),
    Profile(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (value){
          setState(() {
            _pageIndex = value;
          });
        },
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.yellow.shade900,
        items: [
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'HOME',),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.doc_text_search), label: 'CATEGORIES',),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'STORE',),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.shopping_cart), label: 'CART',),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.search), label: 'SEARCH',),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.chat_bubble), label: 'CHAT',),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.profile_circled), label: 'ACCOUNT',),
      ]),

      body:  _pages[_pageIndex],
    );
  }
}