import 'dart:ui';

import 'package:azan/register/resetPassword.dart';
import 'package:azan/register/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../ble/device_list.dart';
import '../constants.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final emailUserController = TextEditingController();
  final passwordController = TextEditingController();
  late String emailUser;
  late String password;
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
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.07),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
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
                  TextFormField(
                    controller: emailUserController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.people, color: Colors.brown.shade700,),
                      labelText: 'Email',
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
                    onChanged: (value) {
                      emailUser = value;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      controller: passwordController,
                      keyboardType: TextInputType.text,
                      obscureText: showPassword,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Colors.brown.shade700,),
                        suffixIcon: IconButton(
                          icon: Icon(showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,color: Colors.brown.shade700,),
                          onPressed: () {
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
                              return TextStyle(color: color, letterSpacing: 1.3, fontSize: 20);
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
                      onChanged: (value) {
                        password = value;
                      },
                    ),
                  ),
                  Visibility(
                    visible: notFound,
                    child: Text('The email is not found'),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ResetPassword()));
                      },
                      child: Text(
                        'Forget Password?',
                        style: TextStyle(color: Colors.red.shade700, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width*.8,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final userCredential = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: emailUser, password: password);
                          // print('email1 $emailUser');
                          if (userCredential != null) {
                            setState(() {
                              notFound = false;
                            });
                            final userSnapshot = await FirebaseFirestore.instance
                                .collection('users')
                                .where('user email', isEqualTo: emailUser)
                                .get();
                            // print('pass $password');
                            print('$userSnapshot');
                            if (userSnapshot.docs.isNotEmpty) {
                              final username = userSnapshot.docs.first.id;
                              // print('Username: $username');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ScanningListScreen(
                                            userName: username,
                                          )));
                            } else {
                              setState(() {
                                notFound = true;
                              });
                            }
                          }
                        } on FirebaseAuthException catch (e) {
                          // Handle FirebaseAuthException
                          print(
                              'Firebase Auth Error: ${e.code}'); // Print the error code
                          print('Firebase Auth Error Message: ${e.message}');
                        } catch (e) {
                          // Handle other exceptions
                          print('Other Error: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.brown,
                        backgroundColor: Colors.brown.shade600,
                        disabledForegroundColor: Colors.brown.shade600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),),
                      child: const Text('Log In', style: TextStyle(color: Colors.white, fontSize: 24,),),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUp()));
                    },
                    child: Text(
                      'Don\'t Have An Account?',
                      style: TextStyle(color: Colors.red.shade700, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
