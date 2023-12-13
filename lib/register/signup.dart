import 'package:azan/register/login.dart';
import 'package:azan/register/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../constants.dart';

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
  late String userName;
  late String password;
  // @override
  // void initState() {
  //   super.initState();
  //   email = '';
  // }

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width*.07),
          child: Column(
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
                  // final docsIDs = await FirebaseFirestore.instance.collection('users').get().then(
                  //         (value) => value.docs.map((e) => e.id).toList());
                  // if(docsIDs.contains(value)){
                  //   setState(() {
                  //     userConfirm = true;
                  //   });
                  // }
                  // else{
                  //   setState(() {
                  //     userConfirm = false;
                  //   });
                    userName = value;
                  // }
                },
              ),
              // Visibility(visible:userConfirm,child: Text('username is already in use')),
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
              // Visibility(visible:emailConfirm,child: Text('the email is already in use',style: TextStyle(color: Colors.red),)),
              ElevatedButton(
                onPressed: () async {
                  try{
                    print('email $email');
                    print('pass $password');
                    final newUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
                    print('email $newUser');
                    // if(newUser != null){
                      // final docsIDs = await FirebaseFirestore.instance.collection('users').get().then(
                      //         (value) => value.docs.map((e) => e.id).toList());
                      print('hi 2');
                      // if(!docsIDs.contains(userName) || docsIDs.isEmpty){
                    await FirebaseFirestore.instance.collection('users').doc(userName).set(
                        {
                          'email': email,
                          'password': password,
                        });
                        await Navigator.push(context,MaterialPageRoute(builder: (context)=>Register(name: userName,)));
                      // }
                    // }
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
      ),
    );
  }
}
