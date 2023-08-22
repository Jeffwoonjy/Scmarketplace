import 'package:flutter/material.dart';
import 'package:scmarketplace/utills/colour.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPresed;
  
  const MyTextBox({
    super.key,
    required this.text,
    required this.sectionName,
    this.onPresed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: hexStringToColor("FFC0CB"),
        borderRadius: BorderRadius.circular(0),
        ),
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      margin: const EdgeInsets.only(left:20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //section name
              Text(
                sectionName,
                style: TextStyle(color: hexStringToColor("E74C3C")),
              ),
              //edit button
              IconButton(onPressed: onPresed,
                icon: Icon(
                  Icons.settings,
                  color: hexStringToColor("000000"),
                ),
              ),
            ],
          ),
          //text
          Text(text),
        ],
      ),
    );
  }
}