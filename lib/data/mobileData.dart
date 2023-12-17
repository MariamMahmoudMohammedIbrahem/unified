import 'package:azan/functions.dart';
import 'package:flutter/material.dart';

class MobileData extends StatefulWidget {
  const MobileData({super.key, required this.name});
  final String name;

  @override
  State<MobileData> createState() => _MobileDataState();
}

class _MobileDataState extends State<MobileData> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    String initial = widget.name.isNotEmpty ? widget.name[0].toUpperCase() : ''; // Get the first letter
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: [
          Container(
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
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
            decoration: BoxDecoration(
            color: Colors.blue,
            ),
            child: Text(
            'Drawer Header',
            style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            ),
            ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Navigate to the home screen or perform an action
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Navigate to the settings screen or perform an action
                Navigator.pop(context);
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
