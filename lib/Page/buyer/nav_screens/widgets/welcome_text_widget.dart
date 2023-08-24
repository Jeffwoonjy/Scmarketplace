import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scmarketplace/Page/buyer/nav_screens/search_screen.dart';

class WelcomeText extends StatelessWidget {
  const WelcomeText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 25, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Text('Yo, What Are You\n Looking For 👀',
        style: TextStyle(
          fontSize: 22, 
          fontWeight: FontWeight.bold
          ),
          ),
    
        Container(
        child: IconButton(
        icon: Icon(Icons.search),
          onPressed: () { 
            Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchScreen();
      }));
    }
  )
)

          
      ],
      ),
    );
  }
}