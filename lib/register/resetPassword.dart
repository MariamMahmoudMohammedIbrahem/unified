import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ResetPassword extends StatefulWidget {

  static String id = 'reset_password_page';

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
            return const AlertDialog(
              content: Text('Password reset link sent! check your email'),
            );
          }
      );
    } catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.toString()),
            );
          }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(

      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Container(
        width: .9*width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 5),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: TextFormField(
                style: TextStyle(color: Colors.grey.shade600,fontSize: 17),
                // keyboardType: insertedtype,
                textAlign: TextAlign.start,
                onChanged: (value) {
                  _email = value;
                },
                // obscureText: obscureText,
                decoration: InputDecoration(
                  labelText: 'insert the confirmed email',
                  enabledBorder: UnderlineInputBorder( //<-- SEE HERE
                    borderSide: BorderSide(
                        width: 3, color: Colors.grey.shade600),
                  ),

                  prefixIcon: Icon(
                    Icons.email,
                    color: Colors.grey.shade600,
                  ),
                  floatingLabelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
                    final Color color = states.contains(MaterialState.error)
                        ? Theme.of(context).colorScheme.error
                        : Colors.grey.shade600;
                    return TextStyle(color: color, letterSpacing: 1.3);
                  }),
                  labelStyle:
                  MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
                    final Color color = states.contains(MaterialState.error)
                        ? Theme.of(context).colorScheme.error
                        : Colors.grey.shade600;
                    return TextStyle(color: color, letterSpacing: 1.3);
                  }),
                ),
              ),
            ),

            const SizedBox(height: 10,),
            SizedBox(
              width: width*.2,
              child: ElevatedButton(
                  style:ElevatedButton.styleFrom(
                    elevation: 26,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey),
                      borderRadius:
                      BorderRadius.all(Radius.circular(20)),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: passwordReset,
                  child: const Text(
                    'Reset Password',
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}