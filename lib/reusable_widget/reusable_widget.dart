import 'package:flutter/material.dart';

//logo 
Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
  );
}

//textfield
TextField reuseTextField(String text, IconData icon, bool isPasswordType, TextEditingController controller){
    return TextField(controller: controller,
    //checkPassword
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    //decoration
    cursorColor: Colors.white,
    style: TextStyle(color: Colors.white.withOpacity(0.9)),
    decoration: InputDecoration(prefixIcon: Icon(icon, color: Colors.white70,),
    //label
    labelText: text,
    labelStyle: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold),
    filled: true,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    fillColor: Colors.white.withOpacity(0.3),//textfieldBackground
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
    ),
    keyboardType: isPasswordType ? TextInputType.visiblePassword : TextInputType.emailAddress,
    );
}

//Sign in button and Sign up button
Container SignInUpButton(
  BuildContext context, bool isLogin, Function onTap){
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    //Button
    child: ElevatedButton(onPressed: () { onTap(); },
    //ButtonStyle
    style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states){
        if (states.contains(MaterialState.pressed)) {
          return Colors.black;  
        }
        return Colors.white;
    }),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
      child: Text(isLogin ? 'Log In' : 'Sign Up',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
    ),
  );
}
