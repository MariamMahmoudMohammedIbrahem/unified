// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../feedback/feedback1.dart';

class Register extends StatefulWidget {

  const Register({Key? key, required this.name,}) :super(key:key);
final String name;

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final phoneController = TextEditingController();
  final mosqueController = TextEditingController();
  final areaController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late String phone;
  late String area;
  late String mosque;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          TextFormField(
            controller: phoneController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.phone),
              labelText: 'phone',
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
              phone = value;
            },
          ),
          TextFormField(
            controller: mosqueController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.mosque),
              labelText: 'Mosque',
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
              mosque = value;
            },
          ),
          TextFormField(
            controller: areaController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.area_chart),
              labelText: 'Area',
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
              area = value;
            },
          ),
          ElevatedButton(
            onPressed: ()async{
              try{
                await FirebaseFirestore.instance.collection('users').doc(widget.name).update(
                    {
                      'phone': phone,
                      'mosque': mosque,
                      'area': area,
                    });
                await Navigator.push(context,MaterialPageRoute(builder: (context)=>FeedbackRegister(name: widget.name,)));
              }
              on FirebaseException catch (e){

              }
            },
            child: const Text('Sign Up2'),
          ),
        ],
      ),
    );
  }
}
