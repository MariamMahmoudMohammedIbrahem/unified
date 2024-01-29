import 'dart:ui';

import 'package:azan/register/login.dart';
import 'package:azan/register/register.dart';
import 'package:azan/t_key.dart';
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
      body: Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/pattern.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width*.07),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: CircleAvatar(
                        backgroundColor: Colors.brown.shade200,
                        radius: 120,
                        child: const CircleAvatar(
                          backgroundColor: Colors.brown,
                          radius: 112,
                          child: CircleAvatar(
                            backgroundImage: AssetImage(
                              'images/appIcon.jpg',
                            ),
                            radius: 100,
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Colors.brown.shade700,),
                        labelText: TKeys.email.translate(context),
                        floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                                (Set<MaterialState> states) {
                              final Color color = states.contains(MaterialState.error)
                                  ? Theme.of(context).colorScheme.error
                                  : Colors.brown.shade700;
                              return TextStyle(color: color, letterSpacing: 1.3,fontWeight: FontWeight.bold,fontSize: 18);
                            }),
                        labelStyle: MaterialStateTextStyle.resolveWith(
                                (Set<MaterialState> states) {
                              final Color color = states.contains(MaterialState.error)
                                  ? Theme.of(context).colorScheme.error
                                  : Colors.brown.shade700;
                              return TextStyle(color: color, letterSpacing: 1.3);
                            }),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide(width: 3, color: Colors.brown.shade800 ,),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide(width: 1, color: Colors.brown ,),
                        ),
                      ),
                      onChanged:(value){
                        setState(() {
                          email = value;
                        });
                      },
                    ),
                  ),
                  TextFormField(
                    controller: userController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.people, color: Colors.brown.shade700,),
                      labelText: TKeys.userName.translate(context),
                      floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                              (Set<MaterialState> states) {
                            final Color color = states.contains(MaterialState.error)
                                ? Theme.of(context).colorScheme.error
                                : Colors.brown.shade700;
                            return TextStyle(color: color, letterSpacing: 1.3,fontWeight: FontWeight.bold,fontSize: 18);
                          }),
                      labelStyle: MaterialStateTextStyle.resolveWith(
                              (Set<MaterialState> states) {
                            final Color color = states.contains(MaterialState.error)
                                ? Theme.of(context).colorScheme.error
                                : Colors.brown.shade700;
                            return TextStyle(color: color, letterSpacing: 1.3);
                          }),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(width: 3, color: Colors.brown.shade800 ,),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(width: 1, color: Colors.brown ,),
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
                  Visibility(visible:userConfirm ,child: Text(TKeys.userNameError.translate(context),style: TextStyle(color: Colors.red),)),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      controller: passwordController,
                      keyboardType: TextInputType.text,
                      obscureText: showPassword,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Colors.brown.shade700,),
                        suffixIcon: IconButton(
                          icon: Icon(showPassword?Icons.visibility:Icons.visibility_off, color: Colors.brown.shade700,),
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
                        labelText: TKeys.password.translate(context),
                        floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                                (Set<MaterialState> states) {
                              final Color color = states.contains(MaterialState.error)
                                  ? Theme.of(context).colorScheme.error
                                  : Colors.brown.shade700;
                              return TextStyle(color: color, letterSpacing: 1.3,fontWeight: FontWeight.bold,fontSize: 18);
                            }),
                        labelStyle: MaterialStateTextStyle.resolveWith(
                                (Set<MaterialState> states) {
                              final Color color = states.contains(MaterialState.error)
                                  ? Theme.of(context).colorScheme.error
                                  : Colors.brown.shade700;
                              return TextStyle(color: color, letterSpacing: 1.3);
                            }),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide(width: 3, color: Colors.brown.shade800 ,),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide(width: 1, color: Colors.brown ,),
                        ),
                      ),
                      onChanged:(value){
                        password = value;
                      },
                    ),
                  ),
                  SizedBox(
                    width: width*.8,
                    child: ElevatedButton(
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
                                      TKeys.weakPassword.translate(context),
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
                                      TKeys.accountExist.translate(context),
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
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.brown,
                        backgroundColor: Colors.brown.shade600,
                        disabledForegroundColor: Colors.brown.shade600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),),
                      child: Text(TKeys.signUp.translate(context), style: TextStyle(color: Colors.white, fontSize: 24,),),
                    ),
                  ),
                  TextButton(
                    onPressed: (){
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>const LogIn()));
                    },
                    child: Text(TKeys.accountAvailable.translate(context),style: TextStyle(color: Colors.red.shade700, fontSize: 18, fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
            ),
        ),
          ),
        ],
      ),
    );
  }
}
