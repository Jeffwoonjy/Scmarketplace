import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class WithdrawalScreen extends StatelessWidget {
  late String amount;
  late String name;
  late String mobile;
  late String bankName;
  late String bankHolderName;
  late String bankAccountNumber;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 250, 98, 149),
        elevation: 3,
        title: Text('Withdraw', style: TextStyle(
          color: Colors.white, 
          letterSpacing: 4, 
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),),
      ),

      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Please Enter Amount';
                    }else{
                      return null;
                    }
                  },
                  onChanged: (value){
                    amount = value;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                  ),
                ),
                TextFormField(
                  validator: (value){
                    if(value!.isEmpty){
                      return ('Please Enter Your Full Name');
                    }
                  },
                  onChanged: (value){
                    name = value;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                  ),
                ),
                SizedBox(height: 15,),
                TextFormField(
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Please Enter Your Phone Number';
                    }else{
                      return null;
                    }
                  },
                  onChanged: (value){
                    mobile = value;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                  ),
                ),
                SizedBox(height: 15,),
                TextFormField(
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Please Enter Your Bank Name';
                    }else{
                      return null;
                    }
                  },
                  onChanged: (value){
                    bankName = value;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Bank Name, etc Public Bank',
                  ),
                ),
                SizedBox(height: 15,),
                TextFormField(
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Please Enter Your Bank Account Holder Name';
                    }else{
                      return null;
                    }
                  },
                  onChanged: (value){
                    bankHolderName = value;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Bank Account Holder Name',
                  ),
                ),
                SizedBox(height: 15,),
                TextFormField(
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Please Enter Your Bank Account Number';
                    }else{
                      return null;
                    }
                  },
                  onChanged: (value){
                    bankAccountNumber = value;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Bank Account Number',
                  ),
                ),
                  
                TextButton(onPressed: ()async{
                  if(_formKey.currentState!.validate()){

                    await _firestore
                    .collection('withdrawal')
                    .doc(Uuid().v4())
                    .set({
                      'Amount':amount,
                      'Name':name,
                      'Mobile':mobile,
                      'BankName':bankName,
                      'BankHolderName':bankHolderName,
                      'BankAccountNumber':bankAccountNumber,
                    });
                    print('cool');
                  }else{
                    print('False');
                  }
                }, child: Text('Cash Out',style: TextStyle(
                  fontSize: 18,
                ),),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}