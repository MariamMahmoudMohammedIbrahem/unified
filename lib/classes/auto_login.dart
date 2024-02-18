import 'dart:ui';

import 'package:azan/constants.dart';
import 'package:azan/register/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ble/device_list.dart';
import '../functions.dart';
import '../t_key.dart';

class AutoLogin extends StatefulWidget {
  const AutoLogin({super.key});

  @override
  State<AutoLogin> createState() => _AutoLoginState();
}

class _AutoLoginState extends State<AutoLogin> {
  @override
  void initState() {
    getStoredCredentials();
    // if(emailPass[emailPass.keys.first] == '' && emailPass[emailPass.keys.last] == ''){
    //   LogIn();
    // }
    // else{
    //   signInWithEmailAndPassword(emailPass[emailPass.keys.first]!, emailPass[emailPass.keys.last]!, rememberPassword);
    // }
    super.initState();
  }
  void signInWithEmailAndPassword(
      String email, String password, bool rememberMe) async {
    /*showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown.shade50,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.brown.shade700,
            ),
            const SizedBox(height: 16.0),
            Text(
              TKeys.logging.translate(context),
              style: TextStyle(fontSize: 17, color: Colors.brown.shade700),
            ),
          ],
        ),
      ),
    );*/

    try {
      // Your authentication logic here...
      final userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // if (rememberMe) {
      //   // Store email and password securely
      //   final prefs = await SharedPreferences.getInstance();
      //   await prefs.setString('email', email);
      //   await prefs.setString('password', password);
      // }
      if (userCredential != null) {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('user email', isEqualTo: email)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          final username = userSnapshot.docs.first.id;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> ScanningListScreen(userName: username)));
        }
        // else {
        //   setState(() {
        //     notFound = true;
        //   });
        //   // Hide loading dialog
        //   Navigator.pop(context);
        // }
      }
    } catch (e) {
      // Navigator.pop(context);
      // Show error dialog
      // showDialog(
      //   context: context,
      //   builder: (context) => AlertDialog(
      //     backgroundColor: Colors.brown.shade50,
      //     title: const Text(
      //       'Error',
      //       style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
      //     ),
      //     content: const Text(
      //       'An unexpected error occurred. Please try again.',
      //       style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
      //     ),
      //     actions: [
      //       TextButton(
      //         onPressed: () {
      //           Navigator.pop(context);
      //           getStoredCredentials();
      //         },
      //         child: const Text('OK'),
      //       ),
      //       TextButton(
      //         onPressed: () {
      //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LogIn()));
      //           const LogIn();
      //         },
      //         child: const Text('Login'),
      //       ),
      //     ],
      //   ),
      // );
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> const LogIn()), (route) => false);
    }
  }

  void getStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final password = prefs.getString('password') ?? '';
    if (email.isEmpty && password.isEmpty) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> const LogIn()), (route) => false);
    } else {
      // const AutoLogin();
      signInWithEmailAndPassword(email, password, rememberPassword);
    }
  }
  @override
  Widget build(BuildContext context) {
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Azaan',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 55,color: Colors.brown.shade700,),),
                    const SizedBox(width: 15,),
                    Icon(Icons.mosque_sharp,size: 55,color: Colors.brown.shade700,),
                  ],
                ),
                const SizedBox(height: 30,),
                SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      color: Colors.brown.shade700,
                      strokeWidth: 10,
                    )),
                // const SizedBox(height: 16.0),
                // Text(
                //   TKeys.logging.translate(context),
                //   style: TextStyle(
                //       fontSize: 25,
                //       color: Colors.brown.shade700,
                //       fontWeight: FontWeight.bold),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
