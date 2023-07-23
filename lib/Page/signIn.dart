import 'package:flutter/material.dart';
import 'package:scmarketplace/Page/home.dart';
import 'package:scmarketplace/reusable_widget/reusable_widget.dart';
import 'package:scmarketplace/Page/signUp.dart';
import 'package:scmarketplace/utills/colour.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}): super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          //background colour
          gradient: LinearGradient(colors: [
            hexStringToColor("eaadcd"),
            hexStringToColor("eaadcd")
      ])),
      //background
      child: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).size.height * 0.2, 20, 0),
          child: Column(
            children: <Widget>[
              logoWidget("assets/images/logo1.png"),
              //textField
              //UsernameField
              const SizedBox(
                height: 30,
              ),
              reuseTextField("Enter your Username", Icons.person_outline, false, _emailTextController),
              //PasswordField
              const SizedBox(
                height: 30,
              ),
              reuseTextField("Enter your password", Icons.lock_outline, true, _passwordTextController),
              //Button
              const SizedBox(
                height: 30,
              ),
              SignInUpButton(context, true, () {
              FirebaseAuth.instance.signInWithEmailAndPassword(
                email: _emailTextController.text, 
                password: _passwordTextController.text).then((value){
                  Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const home()));               
                }).onError((error, stackTrace) {
                  print("Error ${error.toString()}");
                });
              }),
              signUpOption()
            ],
        ),
       ),
      ),
     ),
   );
 }

//signUp Action
 Row signUpOption(){
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Don't have an account?",
        style: TextStyle(color: Colors.white70)),
      GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const signUp()));
        },
        child: const Text(
          " Sign Up Now!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        )
      )
    ],
  );
 }
}