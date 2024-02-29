import 'dart:ui';

import 'package:azan/constants.dart';
import 'package:azan/t_key.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../functions.dart';
class ResetPassword extends StatefulWidget {

  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  late String _email;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
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
              padding: EdgeInsets.symmetric(horizontal: width*.07),
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
                    child: Padding(
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
                            // floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                            //         (Set<MaterialState> states) {
                            //       final Color color = states.contains(MaterialState.error)
                            //           ? Theme.of(context).colorScheme.error
                            //           : Colors.brown.shade700;
                            //       return TextStyle(color: color, letterSpacing: 1.3,fontWeight: FontWeight.bold,fontSize: 18);
                            //     }),
                            // labelStyle: MaterialStateTextStyle.resolveWith(
                            //         (Set<MaterialState> states) {
                            //       final Color color = states.contains(MaterialState.error)
                            //           ? Theme.of(context).colorScheme.error
                            //           : Colors.brown.shade700;
                            //       return TextStyle(color: color, letterSpacing: 1.3);
                            //     }),
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
                          onChanged: (value) {
                            _email = value;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    width: width*.8,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.brown,
                          backgroundColor: Colors.brown.shade600,
                          disabledForegroundColor: Colors.brown.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),),
                        onPressed: (){
                          if(_formKey.currentState!.validate()){
                            passwordReset();
                          }
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill input')),
                            );
                          }
                        },
                        child: Text(
                          TKeys.proceed.translate(context),
                          style: const TextStyle(color: Colors.white, fontSize: 24,),
                        )
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
  void passwordReset() {
    try{
      auth.sendPasswordResetEmail(email: _email).then((value) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(TKeys.resetPassword.translate(context)),
              );
            }
        );
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(TKeys.problemOccurred.translate(context)),
            );
          }
      );
    }
  }
}