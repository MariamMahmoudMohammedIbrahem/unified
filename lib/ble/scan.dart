import 'package:flutter/material.dart';

class Scanning extends StatefulWidget {
  const Scanning({super.key});

  @override
  State<Scanning> createState() => _ScanningState();
}

class _ScanningState extends State<Scanning> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(onPressed: (){}, child: const Text('Scan'),),
          ElevatedButton(onPressed: (){}, child: const Text('Skip'),),
        ],
      ),
    );
  }
}
