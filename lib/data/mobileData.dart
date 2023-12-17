import 'package:azan/functions.dart';
import 'package:flutter/material.dart';

class MobileData extends StatefulWidget {
  const MobileData({super.key, required this.name});
  final String name;

  @override
  State<MobileData> createState() => _MobileDataState();
}

class _MobileDataState extends State<MobileData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
