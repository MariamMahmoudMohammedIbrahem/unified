import 'dart:typed_data';
import 'dart:ui';

import 'package:azan/functions.dart';
import 'package:azan/register/resetPassword.dart';
import 'package:azan/register/signup.dart';
import 'package:azan/t_key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../ble/device_list.dart';
import '../constants.dart';
import '../localization_service.dart';

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
  Future<void> _loginUser(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown.shade50,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.brown.shade700,),
            const SizedBox(height: 16.0),
            Text('Logging in...', style: TextStyle(fontSize: 17,color: Colors.brown.shade700),),
          ],
        ),
      ),
    );

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailUser,
        password: password,
      );

      if (userCredential != null) {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('user email', isEqualTo: emailUser)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          final username = userSnapshot.docs.first.id;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ScanningListScreen(userName: username),
            ),
                (route) => false,
          );
        } else {
          setState(() {
            notFound = true;
          });
          // Hide loading dialog
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException
      print('Firebase Auth Error: ${e.code}'); // Print the error code
      print('Firebase Auth Error Message: ${e.message}');
      // Hide loading dialog
      Navigator.pop(context);
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.brown.shade50,
          title: Text(TKeys.error.translate(context)),
          content: Text(TKeys.loginError.translate(context)),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  backgroundColor: Colors.brown.shade600,
                  disabledForegroundColor: Colors.brown.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text(TKeys.ok.translate(context),style: TextStyle(color: Colors.white,fontSize: 18),),
            ),
          ],
        ),
      );
    } catch (e) {
      // Handle other exceptions
      print('Other Error: $e');
      // Hide loading dialog
      Navigator.pop(context);
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.brown.shade50,
          title: const Text('Error', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),),
          content: const Text('An unexpected error occurred. Please try again.', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  final localizationController = Get.find<LocalizationController>();
  @override
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
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.people, color: Colors.brown.shade700,),
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
                    child: Text(TKeys.emailError.translate(context)),
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
                        TKeys.forgetPassword.translate(context),
                        style: TextStyle(color: Colors.red.shade700, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width*.8,
                    child: ElevatedButton(
                      // onPressed: () async {
                      //   try {
                      //     final userCredential = await FirebaseAuth.instance
                      //         .signInWithEmailAndPassword(
                      //             email: emailUser, password: password);
                      //     // print('email1 $emailUser');
                      //     if (userCredential != null) {
                      //       setState(() {
                      //         notFound = false;
                      //       });
                      //       final userSnapshot = await FirebaseFirestore.instance
                      //           .collection('users')
                      //           .where('user email', isEqualTo: emailUser)
                      //           .get();
                      //       if (userSnapshot.docs.isNotEmpty) {
                      //         final username = userSnapshot.docs.first.id;
                      //         // print('Username: $username');
                      //         Navigator.pushAndRemoveUntil(
                      //             context,
                      //             MaterialPageRoute(
                      //                 builder: (context) => ScanningListScreen(
                      //                       userName: username,
                      //                     )),
                      //               (route) => false,);
                      //       } else {
                      //         setState(() {
                      //           notFound = true;
                      //         });
                      //       }
                      //     }
                      //   } on FirebaseAuthException catch (e) {
                      //     // Handle FirebaseAuthException
                      //     print(
                      //         'Firebase Auth Error: ${e.code}'); // Print the error code
                      //     print('Firebase Auth Error Message: ${e.message}');
                      //   } catch (e) {
                      //     // Handle other exceptions
                      //     print('Other Error: $e');
                      //   }
                      // },
                      onPressed: () => _loginUser(context),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.brown,
                        backgroundColor: Colors.brown.shade600,
                        disabledForegroundColor: Colors.brown.shade600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),),
                      child: Text(TKeys.login.translate(context), style: TextStyle(color: Colors.white, fontSize: 24,),),
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
                      TKeys.noAccount.translate(context),
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
