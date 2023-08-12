import 'package:flutter/material.dart';
import 'package:scmarketplace/Page/allChat.dart';
import 'package:scmarketplace/Page/profile.dart';
import 'package:scmarketplace/Page/search.dart';
import 'package:scmarketplace/Page/signUp.dart';
import 'package:scmarketplace/utills/colour.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  Image logoWidget(String imageName) {
    return Image.asset(
      imageName,
      fit: BoxFit.fitWidth,
      width: 240,
      height: 240,
    );
  }

  TextField _textField(String text, IconData icon, bool isPasswordType, TextEditingController controller){
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          //background colour
          gradient: LinearGradient(colors: [
            hexStringToColor("FFC0CB"),
            hexStringToColor("FFC0CB")
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
              _textField("Enter your Username", Icons.person_outline, false, _emailTextController),
              //PasswordField
              const SizedBox(
                height: 30,
              ),
              _textField("Enter your password", Icons.lock_outline, true, _passwordTextController),
              //Button
              const SizedBox(
                height: 30,
              ),
              _signInButton(context, true, () {
              FirebaseAuth.instance.signInWithEmailAndPassword(
                email: _emailTextController.text, 
                password: _passwordTextController.text).then((value){
                  Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AllChat()));               
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

Container _signInButton(
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

//signUp Action
 Row signUpOption(){
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Don't have an account?",
        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 18),),
      GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUp(),),);
        },
        child: const Text(
          " Sign Up Now!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
        ),
      )
    ],
  );
 }
}