
import 'package:azan/data/mobileData.dart';
import 'package:azan/feedback/feedback1.dart';
import 'package:azan/register/resetPassword.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: emailUserController,
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
              emailUser = value;
            },
          ),
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
          Visibility(visible: notFound, child: Text('The email is not found'),),
          ElevatedButton(
            onPressed: () async {
              try {
                final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailUser, password: password);
                // print('email1 $emailUser');
                if (userCredential != null) {
                  setState(() {
                    notFound = false;
                  });
                  final userSnapshot = await FirebaseFirestore.instance.collection('users').where('user email', isEqualTo: emailUser).get();
                  // print('pass $password');
                  print('$userSnapshot');
                  if (userSnapshot.docs.isNotEmpty) {
                    final username = userSnapshot.docs.first.id;
                    // print('Username: $username');
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>MobileData(name: username,)));
                  } else {
                    setState(() {
                      notFound = true;
                    });

                  }
                }
              } on FirebaseAuthException catch (e) {
                // Handle FirebaseAuthException
                print('Firebase Auth Error: ${e.code}'); // Print the error code
                print('Firebase Auth Error Message: ${e.message}');
              } catch (e) {
                // Handle other exceptions
                print('Other Error: $e');
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: (){
              Navigator.push(context,MaterialPageRoute(builder: (context)=>const ResetPassword()));
            },
            child: const Text('forget password?',style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
