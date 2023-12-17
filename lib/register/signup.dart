import 'package:azan/register/login.dart';
import 'package:azan/register/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants.dart';
import '../functions.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final emailController = TextEditingController();
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late String email;
  late String userName = '';
  late String password;
  void initState() {
    super.initState();
    getDocumentIDs();
  }

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width*.07),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.people),
                labelText: 'email',
                floatingLabelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
                  final Color color = states.contains(MaterialState.error)
                      ? Theme.of(context).colorScheme.error
                      : Colors.brown.shade900;
                  return TextStyle(color: color, letterSpacing: 1.3);
                }),
                labelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
                  final Color color = states.contains(MaterialState.error)
                      ? Theme.of(context).colorScheme.error
                      : Colors.brown.shade800;
                  return TextStyle(color: color, letterSpacing: 1.3);
                }),
                border: const UnderlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(width: 1, color: Colors.black),
                ),
              ),
              onChanged:(value){
                setState(() {
                  email = value;
                });
              },
            ),
            TextFormField(
              controller: userController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.people),
                labelText: 'username',
                floatingLabelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
                  final Color color = states.contains(MaterialState.error)
                      ? Theme.of(context).colorScheme.error
                      : Colors.brown.shade900;
                  return TextStyle(color: color, letterSpacing: 1.3);
                }),
                labelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
                  final Color color = states.contains(MaterialState.error)
                      ? Theme.of(context).colorScheme.error
                      : Colors.brown.shade800;
                  return TextStyle(color: color, letterSpacing: 1.3);
                }),
                border: const UnderlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(width: 1, color: Colors.black),
                ),
              ),
              onChanged:(value){
                setState(() {
                  if(usersIDs.contains(value)){
                    userConfirm = true;
                  }
                  else{
                    userConfirm = false;
                    userName = value;
                  }
                });
              },
            ),
            Visibility(visible:userConfirm ,child: Text('this username is in use',style: TextStyle(color: Colors.red),)),
            TextFormField(
              controller: passwordController,
              keyboardType: TextInputType.text,
              obscureText: showPassword,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(showPassword?Icons.visibility:Icons.visibility_off),
                  onPressed: (){
                    if (showPassword == true) {
                      setState(() {
                        showPassword = false;
                      });
                    } else {
                      setState(() {
                        showPassword = true;
                      });
                    }
                  },
                ),
                labelText: 'password',
                floatingLabelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
                  final Color color = states.contains(MaterialState.error)
                      ? Theme.of(context).colorScheme.error
                      : Colors.brown.shade900;
                  return TextStyle(color: color, letterSpacing: 1.3);
                }),
                labelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
                  final Color color = states.contains(MaterialState.error)
                      ? Theme.of(context).colorScheme.error
                      : Colors.brown.shade800;
                  return TextStyle(color: color, letterSpacing: 1.3);
                }),
                border: const UnderlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(width: 1, color: Colors.black),
                ),
              ),
              onChanged:(value){
                password = value;
              },
            ),
            ElevatedButton(
              onPressed: () async {
                try{
                  await _auth.createUserWithEmailAndPassword(email: email, password: password);
                  await FirebaseFirestore.instance.collection('users').doc(userName).set(
                      {
                        'user email': email,
                        'user password': password,
                      });
                  await Navigator.push(context,MaterialPageRoute(builder: (context)=>Register(name: userName,)));
                } on FirebaseException catch (e) {
                  if(e.code == 'weak-password'){
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(
                              'The password provided is too weak.',
                              style: TextStyle(
                                  color: Colors.red
                              ),
                            ),
                          );
                        }
                    );
                  } else if(e.code == 'email-already-in-use'){
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(
                              'The account already exists for that email.',
                              style: TextStyle(
                                  color: Colors.red
                              ),
                            ),
                          );
                        }
                    );
                  }
                }
              },
              child: const Text('Sign Up'),
            ),
            TextButton(
              onPressed: (){
                Navigator.push(context,MaterialPageRoute(builder: (context)=>const LogIn()));
              },
              child: const Text('Already have an acount?'),
            ),
          ],
        ),
      ),
    );
  }
}
