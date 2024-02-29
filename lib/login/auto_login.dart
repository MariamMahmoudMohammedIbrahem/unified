import 'dart:ui';

import 'package:azan/constants.dart';
import 'package:azan/login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ble/device_list.dart';

class AutoLogin extends StatefulWidget {
  const AutoLogin({super.key});

  @override
  State<AutoLogin> createState() => _AutoLoginState();
}

class _AutoLoginState extends State<AutoLogin> {

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
  @override
  void initState() {
    getStoredCredentials();
    super.initState();
  }
  void signInWithEmailAndPassword(
      String email, String password, bool rememberMe) {

    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).then((value) async {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('user email', isEqualTo: email)
            .get();
        usernameAuto = userSnapshot.docs.first.id;
      }).then((value) {
        if(usernameAuto.isNotEmpty){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> ScanningListScreen(userName: usernameAuto)));
        }
        else{

        }
      });
    } catch (e) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> const LogIn()), (route) => false);
    }
  }
  void getStoredCredentials() async {
    prefs = await SharedPreferences.getInstance();
    prefsEmail = prefs.getString('email') ?? '';
    prefsPassword = prefs.getString('password') ?? '';
    checkStoredCredentials();
  }
  void checkStoredCredentials() {
    if (prefsEmail.isEmpty && prefsPassword.isEmpty) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> const LogIn()), (route) => false);
    } else {
      // const AutoLogin();
      signInWithEmailAndPassword(prefsEmail, prefsPassword, rememberPassword);
    }
  }
}
