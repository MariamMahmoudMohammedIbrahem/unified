import 'package:azan/account/account_details.dart';
import 'package:azan/feedback/feedback1.dart';
import 'package:azan/functions.dart';
import 'package:azan/register/login.dart';
import 'package:azan/register/resetPassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class MobileData extends StatefulWidget {
  const MobileData({super.key, required this.name});
  final String name;

  @override
  State<MobileData> createState() => _MobileDataState();
}

class _MobileDataState extends State<MobileData> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _auth = FirebaseAuth.instance;
  signOut() async {
    await _auth.signOut();
    Navigator.push(context,MaterialPageRoute(builder: (context)=>const LogIn()));
  }
  @override
  Widget build(BuildContext context) {
    initial = widget.name.isNotEmpty ? widget.name[0].toUpperCase() : ''; // Get the first letter
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.deepPurple, // You can change the background color as needed
                shape: BoxShape.circle,
              ),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  child: Text(initial,
                    style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    ),
                  ),
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 150,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                color: Colors.grey,
                ),
                child: Text(
                  widget.name,
                  style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Account Details'),
              onTap: () {
                Navigator.push(context,MaterialPageRoute(builder: (context)=>AccountDetails(name: widget.name,)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.key_sharp),
              title: const Text('Change Password'),
              onTap: () {
                Navigator.push(context,MaterialPageRoute(builder: (context)=>const ResetPassword()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('Complain'),
              onTap: () {
                Navigator.push(context,MaterialPageRoute(builder: (context)=>FeedbackRegister(name: widget.name,)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Logout'),
              onTap: () {
                //logout
                signOut();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: (){
                getCurrentDateTime();
              },
              child: const Text('time'),
          ),
        ],
      ),
    );
  }
}
