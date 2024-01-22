import 'dart:ui';

import 'package:azan/t_key.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ResetPassword extends StatefulWidget {

  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  late String _email;
  final _auth = FirebaseAuth.instance;

  Future passwordReset() async {
    try{
      await _auth.sendPasswordResetEmail(email: _email);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(TKeys.resetPassword.translate(context)),
            );
          }
      );
    } catch (e) {
      print(e);
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
                  TextFormField(
                    style: TextStyle(color: Colors.grey.shade600,fontSize: 17),
                    textAlign: TextAlign.start,
                    onChanged: (value) {
                      _email = value;
                    },
                    // obscureText: obscureText,
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
                        onPressed: passwordReset,
                        child: Text(
                          TKeys.resetPassword.translate(context),
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
}