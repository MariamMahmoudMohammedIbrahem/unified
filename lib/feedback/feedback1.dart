// import 'package:azan/feedback/feedback2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

import '../ble/device_list.dart';
import '../constants.dart';

class FeedbackRegister extends StatefulWidget {
  const FeedbackRegister({
    Key? key,
    required this.name,
  }) : super(key: key);
  final String name;

  @override
  State<FeedbackRegister> createState() => _FeedbackRegisterState();
}

class _FeedbackRegisterState extends State<FeedbackRegister> {
  final controllerName = TextEditingController();
  final controllerArea = TextEditingController();
  final controllerNote = TextEditingController();
  late String selectedOption = '';
  late String msg = '';
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context,true);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.brown.shade700,
            )),
        title: Text(
          'Complain',
          style: TextStyle(
              color: Colors.brown.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SizedBox(
            width: width,
            child: Image.asset('images/feedback.jpg'),
          ),
          // options
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * .07),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How can we help you',
                  style: TextStyle(
                      color: Colors.brown.shade700,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Radio(
                            value: 'Azaan Time',
                            groupValue: selectedOption,
                            activeColor: Colors.brown,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value!;
                              });
                            },
                          ),
                          Text(
                            'Azaan Time',
                            style: TextStyle(
                              color: Colors.brown.shade700,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: 'All LEDs On',
                            groupValue: selectedOption,
                            activeColor: Colors.brown,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value!;
                              });
                            },
                          ),
                          Text(
                            'All LEDs On',
                            style: TextStyle(
                              color: Colors.brown.shade700,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: 'Noise in Azaan',
                            groupValue: selectedOption,
                            activeColor: Colors.brown,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value!;
                              });
                            },
                          ),
                          Text(
                            'Noise in Azaan',
                            style: TextStyle(
                              color: Colors.brown.shade700,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: 'Other',
                            groupValue: selectedOption,
                            activeColor: Colors.brown,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value!;
                              });
                            },
                          ),
                          Text(
                            'Other',
                            style: TextStyle(
                              color: Colors.brown.shade700,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // leave side note
                Text(
                  'Leave a note (if you want)',
                  style: TextStyle(
                      color: Colors.brown.shade700,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: controllerNote,
                  decoration: InputDecoration(
                    floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                        (Set<MaterialState> states) {
                      final Color color = states.contains(MaterialState.error)
                          ? Theme.of(context).colorScheme.error
                          : Colors.brown.shade900;
                      return TextStyle(color: color, letterSpacing: 1.3);
                    }),
                    labelStyle: MaterialStateTextStyle.resolveWith(
                        (Set<MaterialState> states) {
                      final Color color = states.contains(MaterialState.error)
                          ? Theme.of(context).colorScheme.error
                          : Colors.brown.shade800;
                      return TextStyle(color: color, letterSpacing: 1.3);
                    }),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(width: 1, color: Colors.brown),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(width: 1, color: Colors.brown),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      msg = value;
                    });
                  },
                ),
                // store data
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: width * .8,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.name)
                              .collection('feedback')
                              .add({
                            'problem': selectedOption,
                            'msg': msg,
                          });
                        } catch (error) {
                          print(error);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.brown.shade400,
                          backgroundColor: Colors.brown,
                          disabledForegroundColor: Colors.brown.shade600,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
