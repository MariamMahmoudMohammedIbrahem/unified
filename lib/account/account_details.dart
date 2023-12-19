import 'dart:async';

import 'package:azan/account/edit_details.dart';
import 'package:azan/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class AccountDetails extends StatefulWidget {
  const AccountDetails({super.key, required this.name});
  final String name;

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  @override
  void initState(){
    super.initState();
    setState(() {
      getUserFields(widget.name);
    });
  }
  @override
  void dispose(){}
  void disposeSubscriptions() {
    userSubscription.cancel();
    citiesSubscription.cancel();
  }
  @override

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width*.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hello'),
                        Text(widget.name),
                      ],
                    ),
                  ],
                ),
                IconButton(
                    onPressed: (){
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>AccountEdit(name: widget.name,)));
                    },
                    icon: const Icon(Icons.edit),
                ),
              ],
            ),
            const Text('Sheikh Name'),
            TextFormField(
              enabled: false,
              decoration: InputDecoration(
                label: Text(sheikhName),
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
            ),
            const Text('Email'),
            TextFormField(
              enabled: false,
              decoration: InputDecoration(
                label: Text(email),
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
            ),
            const Text('Phone Number'),
            TextFormField(
              enabled: false,
              decoration: InputDecoration(
                label: Text(sheikhPhone),
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
            ),
            const Text('Area'),
            TextFormField(
              enabled: false,
              decoration: InputDecoration(
                label: Text(area),
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
            ),
            const Text('Mosque'),
            TextFormField(
              enabled: false,
              decoration: InputDecoration(
                label: Text(mosque),
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
            ),
          ],
        ),
      ),
    );
  }
}
