import 'package:azan/feedback/feedback1.dart';
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
          ElevatedButton(
            onPressed: () async {
              try {
                final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailUser, password: password);
                print('email1 $emailUser');
                if (userCredential != null) {
                  final userSnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: emailUser).get();
                  print('pass $password');
                  print('$userSnapshot');
                  if (userSnapshot.docs.isNotEmpty) {
                    final username = userSnapshot.docs.first.id; // Username is the document ID
                    // Use the username as needed...
                    print('Username: $username');
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>FeedbackRegister(name: username,)));
                  } else {
                    // Handle if user not found in Firestore
                  }
                }
              } on FirebaseAuthException catch (e) {
                // Handle FirebaseAuthException
              } catch (e) {
                // Handle other exceptions
              }
            },
            child: const Text('Login'),
          )

          // ElevatedButton(
          //   onPressed: () async {
          //     try {
          //       final user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailUser, password: password);
          //       if (user != null ) {
          //         final docsIDs = await FirebaseFirestore.instance.collection('users').get().then(
          //                 (value) => value.docs.map((e) => e.id).toList());
          //         if(docsIDs.contains(password)){}
          //         else {}
          //       }
          //     } on FirebaseAuthException catch (e) {
          //       if (e.code == 'user-not-found') {
          //         showDialog(
          //             context: context,
          //             builder: (context) {
          //               return AlertDialog(
          //                 content: Text(
          //                   'No user found for that email.',
          //                   style: TextStyle(
          //                       color: Colors.red
          //                   ),),
          //               );
          //             }
          //         );
          //       } else if (e.code == 'wrong-password') {
          //         showDialog(
          //             context: context,
          //             builder: (context) {
          //               return AlertDialog(
          //                 content: Text(
          //                   'Wrong password provided for that user.',
          //                   style: TextStyle(
          //                       color: Colors.red
          //                   ),),
          //               );
          //             }
          //         );
          //       }
          //     }
          //     catch (e) {
          //       print(e);
          //     }
          //   },
          //   child: const Text('Login',),
          // ),
        ],
      ),
    );
  }
}
