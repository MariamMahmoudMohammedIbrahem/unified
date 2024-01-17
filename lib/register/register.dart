// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

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
    // getCurrentDateTime();
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
      body: Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/pattern.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width*.07),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: CircleAvatar(
                      backgroundColor: Colors.brown.shade200,
                      radius: 120,
                      child: const CircleAvatar(
                        backgroundColor: Colors.brown,
                        radius: 112,
                        child: CircleAvatar(
                          backgroundImage: AssetImage(
                            'images/appIcon.jpg',
                          ),
                          radius: 100,
                        ),
                      )),
                ),
                //sheikh name
                Padding(
                  padding: EdgeInsets.only(left: width * .05,bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.only(left: 15.0),
                    decoration: BoxDecoration(color: Colors.brown.shade800.withOpacity(0.7),borderRadius: BorderRadius.circular(20.0)),
                    child: TextFormField(
                      controller: sheikhController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.people, color: Colors.white,),
                        label: const Text('Sheikh Name', style: TextStyle(color: Colors.white),) ,
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
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1.0),
                        ),
                        border: const UnderlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide(width: 1, color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      onChanged:(value){
                        sheikhName = value;
                      },
                    ),
                  ),
                ),
                //phone number
                Padding(
                  padding: EdgeInsets.only(left: width * .05,bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.only(left: 15.0),
                    decoration: BoxDecoration(color: Colors.brown.shade800.withOpacity(0.7),borderRadius: BorderRadius.circular(20.0)),
                    child: TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone, // Set keyboard type for phone number
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Allow only digits
                      LengthLimitingTextInputFormatter(11), // Limit the length to 10 digits
                    ],
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone, color: Colors.white,),
                      label: const Text('Phone',style: TextStyle(color: Colors.white),),
                      error: Text('${validatePhoneNumber(phoneController.text)}',style: TextStyle(color: Colors.white),),
                      floatingLabelStyle: TextStyle(color: Colors.brown.shade900, letterSpacing: 1.3),
                      labelStyle: TextStyle(color: Colors.brown.shade800, letterSpacing: 1.3),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                      ),
                      border: const UnderlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(width: 1, color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    onChanged: (value) {
                      phone = value;
                    },
              ),
                  ),
                ),
                //area
                Padding(
                  padding: EdgeInsets.only(left: width * .05,bottom: 10),
                  child: SizedBox(
                    height: 55,
                    child: PopupMenuButton<String>(
                      onSelected: (String value) async {
                        setState(() {
                          // Handle the selected value
                          areaChanged = false;
                          area= value;
                        });
                        QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Cities').doc(area).collection('Mosques').get();
                        if (querySnapshot.docs.isNotEmpty) {
                          dataList = querySnapshot.docs.map((doc) => doc.id).toSet();
                        }
                        else{
                          dataList = {};
                        }
                      },
                      color: Colors.brown.shade700,
                      itemBuilder: (BuildContext context) {
                        final List<PopupMenuEntry<String>> items = [];
                        for (String item in citiesIDs) {
                          items.add(
                            PopupMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  color: Colors.white,
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
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: areaController,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.area_chart_outlined,color: Colors.white,),
                                      label: const Text('Area',style: TextStyle(color: Colors.white),),
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
                                        borderSide: BorderSide(width: 1, color: Colors.brown),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                    onChanged:(value){
                                      setState(() {
                                        areaChanged = true;
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
                          color: Colors.brown.shade800.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(color: Colors.brown.shade400.withOpacity(.7), width: 2),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                area ==''? 'Select An Area': area,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                              size: 35,),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                //mosque
                Padding(
                  padding: EdgeInsets.only(left: width * .05,bottom: 10),
                  child: SizedBox(
                    height: 55,
                    child: PopupMenuButton<String>(
                      onSelected: (String value) {
                        setState(() {
                          // Handle the selected value
                          mosqueChanged = false;
                          mosque = value;
                        });
                      },
                      color: Colors.brown.shade700,
                      itemBuilder: (BuildContext context) {
                        final List<PopupMenuEntry<String>> items = [];
                        for (String item in dataList) {
                          items.add(
                            PopupMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                          if (item != dataList.last) {
                            items.add(const PopupMenuDivider());
                          }
                        }
                        items.add(
                          PopupMenuItem<String>(
                            value: 'Other',
                            child: Row(
                              children: [
                                const Text(
                                  'Other',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: mosqueController,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.mosque_outlined, color: Colors.white,),
                                      label: const Text('Mosque',style: TextStyle(color: Colors.white),),
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
                                        borderSide: BorderSide(width: 1, color: Colors.brown),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                    onChanged:(value){
                                      setState(() {
                                        mosqueChanged = true;
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
                          color: Colors.brown.shade800.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(color: Colors.brown.shade400.withOpacity(.7), width: 2),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                mosque ==''? 'Select A Mosque': mosque,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                              size: 35,),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: width*.8,
                  child: ElevatedButton(
                    onPressed: ()async{
                      await getCurrentDateTime();
                      try{
                        //edit here
                        await FirebaseFirestore.instance.collection('users').doc(widget.name).update(
                            {
                              'sheikh name': sheikhName,
                              'sheikh phone': phone,
                              'time': '$formattedTime / $formattedDate',
                            });
                        await FirebaseFirestore.instance.collection('users').doc(widget.name).collection('Cities').doc(area).set(
                            {
                              'mosque': mosque,
                              'time': '$formattedTime / $formattedDate',
                            });
                        // if city isn't in the options
                        //updating cities table
                        await FirebaseFirestore.instance.collection('Cities').doc(area).collection('Mosques').doc(mosque).update(
                            {
                              'sheikh name': sheikhName,
                            });
                        for(String name in citiesIDs){
                          if(area!.endsWith(name)){
                            await FirebaseFirestore.instance.collection('Cities').doc(area).set(
                                {
                                  'latitude': '',
                                  'longitude': '',
                                });
                          }
                        }
                        //updating mosques table
                        QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Mosques').where('mosque',isEqualTo: mosque).where('city', isEqualTo: area).get();
                        if (querySnapshot.docs.isNotEmpty) {
                          await FirebaseFirestore.instance.collection('Mosques').doc(querySnapshot.docs.first.id).update(
                              {
                                'connect time':'$formattedTime / $formattedDate',
                                'sheikh name': sheikhName,
                              });
                        }
                        else {
                          await FirebaseFirestore.instance.collection('Mosques').add(
                              {
                                'mosque':mosque,
                                'city':area,
                                'connect time':'$formattedTime / $formattedDate',
                                'sheikh name': sheikhName,
                              });
                        }
                        await Navigator.push(context,MaterialPageRoute(builder: (context)=>ScanningListScreen(userName: widget.name,)));
                      }
                      on FirebaseException catch (e){
                        print('error is => $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.brown.shade400,
                        backgroundColor: Colors.brown,
                        disabledForegroundColor: Colors.brown.shade600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    child: const Text('Sign Up',style: TextStyle(color: Colors.white, fontSize: 24),),
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
