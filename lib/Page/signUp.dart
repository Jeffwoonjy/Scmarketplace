import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scmarketplace/Page/profile.dart';
import 'package:scmarketplace/Page/signIn.dart';
import 'package:scmarketplace/utills/colour.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _confirmPasswordTextController = TextEditingController();
  final TextEditingController _addressTextController = TextEditingController();

  bool _isPasswordMatch() {
  return _passwordTextController.text == _confirmPasswordTextController.text;
  }

  TextField _textField(String text, IconData icon, bool isPasswordType, TextEditingController controller){
    return TextField(
    controller: controller,
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
    keyboardType: isPasswordType 
      ? TextInputType.visiblePassword 
      : TextInputType.emailAddress,
    );
}

  @override
  void dispose(){
    _emailTextController.dispose();
    _passwordTextController.dispose();
    _confirmPasswordTextController.dispose();
    _userNameTextController.dispose();
    _addressTextController.dispose();
    super.dispose();
  }

  //fucntion original place
  Future addUserDetails(UserCredential userCredential, String username, String email, String address) async {   
    String userId = userCredential.user!.uid;

    await FirebaseFirestore.instance
    .collection("Users")
    .doc(userCredential.user!.uid)
    .set({
    'userId': userId,
    'username': username,
    'email': email,
    'address': address,
    'displayName': username,
    });
  }

  //Sign up button
  Container _signUpButton(BuildContext context, Function onTap) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
      //Button
      child: ElevatedButton(
        onPressed: () {
          if (_isPasswordMatch()) {
            onTap(_userNameTextController.text); // Proceed with signup if passwords match
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Password Mismatch"),
                  content: const Text("Passwords do not match. Please try again."),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("OK"),
                    ),
                  ],
                );
              },
            );
          }
        },
        //ButtonStyle
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black;
            }
            return Colors.white;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
        child: const Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

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
            hexStringToColor("FFC0CB"),
            hexStringToColor("FFC0CB")
        ])),

      child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
          child: Column(
            children: <Widget>[
              //UsernameField
              const SizedBox(
                height: 20,
              ),
              _textField("Enter your Username", Icons.person_outline, false, _userNameTextController),
              //EmailField
              const SizedBox(
                height: 20,
              ),
              _textField("Enter your Email", Icons.person_outline, false, _emailTextController),
              //AddressField
              const SizedBox(
                height: 20,
              ),
              _textField("Enter your Address", Icons.person_outline, false, _addressTextController),
              //PasswordField
              const SizedBox(
                height: 20,
              ),
              _textField("Enter your Password", Icons.lock_outline, true, _passwordTextController),
              //signUp Button
              const SizedBox(
                height: 20,
              ),
              _textField("Confirm your Password", Icons.lock_outline, true, _confirmPasswordTextController),
              const SizedBox(
                height: 20,
              ),
              //SignUpFunction
              _signUpButton(context, (String displayName) async {
                try{
                // Firebase Authentication
                UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: _emailTextController.text, 
                  password: _passwordTextController.text,
                );

                //add user details  
                await addUserDetails(
                  userCredential,
                  _userNameTextController.text.trim(),
                  _emailTextController.text.trim(),
                  _addressTextController.text.trim()
                );

                await userCredential.user!.updateDisplayName(displayName);

                Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const Profile(),
                    ));
                  } catch (error) {
                    print("Error: ${error.toString()}");
                  }
                }),
                signInOption(),
            ],
          ),
      ))),
    );
  }

  Row signInOption(){
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("I already have an account!",
        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 18),),
      GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SignIn(),),);
        },
        child: const Text(
          " Login Now!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
        ),
      )
    ],
  );
 }
}

extension UserCredentialExtension on UserCredential {
  Future<void> updateDisplayName(String displayName) async {
    await user!.updateDisplayName(displayName);
    await user!.reload();
  }
}