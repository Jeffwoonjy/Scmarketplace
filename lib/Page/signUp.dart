import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scmarketplace/Page/home.dart';
import 'package:scmarketplace/reusable_widget/reusable_widget.dart';
import 'package:scmarketplace/utills/colour.dart';

class signUp extends StatefulWidget {
  const signUp({super.key});

  @override
  State<signUp> createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Sign Up",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
            hexStringToColor("eaadcd"),
            hexStringToColor("eaadcd")
        ])),

      child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
          child: Column(
            children: <Widget>[
              //UsernameField
              const SizedBox(
                height: 20,
              ),
              reuseTextField("Enter your Username", Icons.person_outline, false, _userNameTextController),
              //EmailField
              const SizedBox(
                height: 20,
              ),
              reuseTextField("Enter your Email", Icons.person_outline, false, _emailTextController),
              //PasswordField
              const SizedBox(
                height: 20,
              ),
              reuseTextField("Enter your Password", Icons.lock_outline, true, _passwordTextController),
              //signUp Button
              const SizedBox(
                height: 20,
              ),
              SignInUpButton(context, false, (){
              //firebase Authentication
              FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: _emailTextController.text, 
                password: _passwordTextController.text).then((value){
                  print ("You have created a new account");
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const home()));
                }).onError((error, stockTrace){
                  print("Error ${error.toString()}");
                });
              })
            ],
          ),
      ))),
    );
  }
}