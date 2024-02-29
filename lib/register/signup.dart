import 'dart:ui';

import 'package:azan/login/login.dart';
import 'package:azan/register/register.dart';
import 'package:azan/t_key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  late String email;
  String userName = '';
  late String password;
  final _formKey = GlobalKey<FormState>();

  @override
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
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: width * .05, bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.only(left: 15.0),
                            decoration: BoxDecoration(
                                color: Colors.brown.shade600.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20.0)),
                            child: TextFormField(
                              controller: emailController,
                              cursorColor: Colors.white,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                } else if (!isEmailValid(value)) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email, color: Colors.white,),
                                label: Text(
                                  TKeys.email.translate(context),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                                ),
                                border: const UnderlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                                  borderSide:
                                  BorderSide(width: 1, color: Colors.white),
                                ),
                              ),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                              onChanged:(value){
                                setState(() {
                                  email = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * .05, bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.only(left: 15.0),
                            decoration: BoxDecoration(
                                color: Colors.brown.shade600.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20.0)),
                            child: TextFormField(
                              controller: userController,
                              cursorColor: Colors.white,
                              keyboardType: TextInputType.name ,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Username is required';
                                } else if (value.length < 3) {
                                  return 'Username must be at least 3 characters long';
                                } else if (!isUsernameValid(value)) {
                                  return 'Enter a valid username \n (only letters, numbers, and underscores are allowed)';
                                } else if(userConfirm){
                                  return TKeys.userNameError.translate(context);
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.people, color: Colors.white,),
                                label: Text(
                                  TKeys.userName.translate(context),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                                ),
                                border: const UnderlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                                  borderSide:
                                  BorderSide(width: 1, color: Colors.white),
                                ),
                              ),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
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
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * .05, bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.only(left: 15.0),
                            decoration: BoxDecoration(
                                color: Colors.brown.shade600.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20.0)),
                            child: TextFormField(
                              controller: passwordController,
                              cursorColor: Colors.white,
                              keyboardType: TextInputType.text,
                              obscureText: showPassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                } else if (value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock, color: Colors.white,),
                                suffixIcon: IconButton(
                                  icon: Icon(showPassword?Icons.visibility:Icons.visibility_off, color: Colors.white,),
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
                                label: Text(
                                  TKeys.password.translate(context),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                                ),
                                border: const UnderlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                                  borderSide:
                                  BorderSide(width: 1, color: Colors.white),
                                ),
                              ),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                              onChanged:(value){
                                password = value;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: width*.8,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Navigate the user to the Home page
                          try{
                            auth.createUserWithEmailAndPassword(email: email, password: password).then((value){
                              FirebaseFirestore.instance.collection('users').doc(userName).set(
                                  {
                                    'user email': email,
                                    'user password': password,
                                  });
                              Navigator.push(context,MaterialPageRoute(builder: (context)=>Register(name: userName,)));
                            });
                          } on FirebaseException catch (e) {
                            if(e.code == 'weak-password'){
                              showErrorDialog(context, TKeys.weakPassword.translate(context));
                            } else if(e.code == 'email-already-in-use'){
                              showErrorDialog(context, TKeys.accountExist.translate(context));
                            }
                          }
                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill input')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.brown,
                        backgroundColor: Colors.brown.shade600,
                        disabledForegroundColor: Colors.brown.shade600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),),
                      child: Text(TKeys.signUp.translate(context), style: const TextStyle(color: Colors.white, fontSize: 24,),),
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

  @override
  void initState() {
    super.initState();
    getDocumentIDs();
  }
}
