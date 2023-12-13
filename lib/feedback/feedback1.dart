// import 'package:azan/feedback/feedback2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants.dart';
class FeedbackRegister extends StatefulWidget {
  const FeedbackRegister({Key? key, required this.name,}) :super(key:key);
  final String name;

  @override
  State<FeedbackRegister> createState() => _FeedbackRegisterState();
}

class _FeedbackRegisterState extends State<FeedbackRegister> {
  final _fireStore = FirebaseDatabase.instance;
  final controllerName = TextEditingController();
  final controllerArea = TextEditingController();
  final controllerNote = TextEditingController();
  late String selectedOption = '';
  late String msg;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width*.07),
        child: ListView(
          children: [
            SizedBox(child: Image.asset('images/mosque.jpeg'),),
            // options
            Text('How can we help you'),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Radio(
                        value: 'option 1',
                        groupValue: selectedOption,
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value!;
                          });
                        },
                      ),
                      const Text('option 1'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 'option 2',
                        groupValue: selectedOption,
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value!;
                          });
                        },
                      ),
                      const Text('option 2'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 'option 3',
                        groupValue: selectedOption,
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value!;
                          });
                        },
                      ),
                      const Text('option 3'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 'option 4',
                        groupValue: selectedOption,
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value!;
                          });
                        },
                      ),
                      const Text('option 4'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 'more',
                        groupValue: selectedOption,
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value!;
                          });
                        },
                      ),
                      const Text('Something Else'),
                    ],
                  ),
                ],
              ),
            ),
            // leave side note
            Text('Leave a note (if you want)'),
            TextFormField(
              controller: controllerNote,
              decoration: InputDecoration(
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
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(width: 1, color: Colors.black),
                  )
              ),
              onChanged: (value){
                setState(() {

                });
                msg = value;
              },
            ),
            // store data
            ElevatedButton(
              onPressed: ()async{
                try{
                  await FirebaseFirestore.instance.collection('users').doc(widget.name).update(
                      {
                        'problem': selectedOption,
                        'msg': msg,
                      });
                }
                catch(error){
                  print(error);
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.indigo[600],
                shape: const StadiumBorder(),
                disabledForegroundColor: Colors.indigo.withOpacity(0.38),
                disabledBackgroundColor: Colors.indigo.withOpacity(0.12),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}