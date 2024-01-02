// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ble/device_list.dart';
import '../constants.dart';
import '../feedback/feedback1.dart';
import '../functions.dart';

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
  final sheikhController = TextEditingController();
  TextEditingController _otherController = TextEditingController();
  List<String> options = [];
  String _selectedOption = '';
  final _auth = FirebaseAuth.instance;
  late String sheikhName;
  late String phone;
  late String area = '';
  late String mosque = '';
  void initState() {
    super.initState();
    getDocumentIDs();
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    List<DropdownMenuItem<String>> dropdownItems = citiesIDs
        .map<DropdownMenuItem<String>>((String option) {
      return DropdownMenuItem<String>(
        value: option,
        child: Text(option),
      );
    }).toList();

    dropdownItems.add(DropdownMenuItem<String>(
      value: 'Other',
      child: Text('Other'),
    ));
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //sheikh name
          TextFormField(
            controller: sheikhController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.people),
              labelText: 'Sheikh Name',
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
              sheikhName = value;
            },
          ),
          //phone number
          TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone, // Set keyboard type for phone number
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // Allow only digits
            LengthLimitingTextInputFormatter(11), // Limit the length to 10 digits
          ],
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.phone),
            labelText: 'Phone',
            hintText: 'Enter phone number',
            errorText: validatePhoneNumber(phoneController.text), // Call validation function
            floatingLabelStyle: TextStyle(color: Colors.brown.shade900, letterSpacing: 1.3),
            labelStyle: TextStyle(color: Colors.brown.shade800, letterSpacing: 1.3),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              borderSide: BorderSide(width: 1, color: Colors.black),
            ),
          ),
          onChanged: (value) {
            phone = value;
          },
        ),
          //area
          Flexible(
            child: SizedBox(
              height: 55,
              child: PopupMenuButton<String>(
                onSelected: (String value) async {
                  setState(() async {
                    // Handle the selected value
                    area= value;
                    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Cities').doc(value).collection('Mosques').get();
                    if (querySnapshot.docs.isNotEmpty) {
                      mosquesIDs = querySnapshot.docs.map((doc) => doc.id).toList();
                    }
                  });
                },
                itemBuilder: (BuildContext context) {
                  final List<PopupMenuEntry<String>> items = [];
                  for (String item in citiesIDs) {
                    items.add(
                      PopupMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                    if (item != citiesIDs.last) {
                      items.add(const PopupMenuDivider());
                    }
                  }
                  items.add(const PopupMenuDivider());
                  items.add(
                    PopupMenuItem<String>(
                      value: 'Other',
                      child: Row(
                        children: [
                          const Text(
                            'Other',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: areaController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.area_chart_outlined),
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
                              onChanged:(value)async{
                                setState(() {
                                  area = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  return items;
                },
                offset: const Offset(0, 50),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          area ==''? 'Select An Area': area,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
          ),
          //mosque
          Flexible(
            child: SizedBox(
              height: 55,
              child: PopupMenuButton<String>(
                onSelected: (String value) {
                  setState(() {
                    // Handle the selected value
                    mosque = value;
                  });
                },
                itemBuilder: (BuildContext context) {
                  final List<PopupMenuEntry<String>> items = [];
                  for (String item in mosquesIDs) {
                    items.add(
                      PopupMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                    if (item != mosquesIDs.last) {
                      items.add(const PopupMenuDivider());
                    }
                  }
                  items.add(const PopupMenuDivider());
                  items.add(
                    PopupMenuItem<String>(
                      value: 'Other',
                      child: Row(
                        children: [
                          const Text(
                            'Other',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: mosqueController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.mosque_outlined),
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
                                setState(() {
                                  mosque = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  return items;
                },
                offset: const Offset(0, 50),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          mosque ==''? 'Select A Mosque': mosque,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: ()async{
              try{
                //edit here
                await FirebaseFirestore.instance.collection('users').doc(widget.name).update(
                    {
                      'sheikh name': sheikhName,
                      'sheikh phone': phone,
                      'time': getCurrentDateTime(),
                    });
                // if city isn't in the options
                await FirebaseFirestore.instance.collection('Cities').doc(area).set(
                    {
                      'latitude':'',
                      'longitude':'',
                    });
                //if mosque isn't in the option
                await FirebaseFirestore.instance.collection('Cities').doc(area).collection('Mosques').doc(mosque).set(
                    {
                      // area:'',
                      // 'connect time':getCurrentDateTime(),
                      'sheikh name': sheikhName,
                    });
                await FirebaseFirestore.instance.collection('Mosques').add(
                    {
                      'mosque':mosque,
                      'city':area,
                      'connect time':getCurrentDateTime(),
                      'sheikh name': sheikhName,
                    });
                await Navigator.push(context,MaterialPageRoute(builder: (context)=>ScanningListScreen(userName: widget.name,)));
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
