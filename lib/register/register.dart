import 'dart:ui';

import 'package:azan/t_key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ble/device_list.dart';
import '../constants.dart';
import '../functions.dart';

class Register extends StatefulWidget {
  const Register({
    Key? key,
    required this.name,
  }) : super(key: key);
  final String name;

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final mosqueController = TextEditingController();
  final areaController = TextEditingController();
  final sheikhController = TextEditingController();
  List<String> options = [];
  late String sheikhName;
  late String phone;
  late String area = '';
  late String mosque = '';
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    String mosqueStatus = TKeys.selectMosque.translate(context);
    String areaStatus = TKeys.selectArea.translate(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .07),
              child: SingleChildScrollView(
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
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          //sheikh name
                          Padding(
                            padding: EdgeInsets.only(left: width * .05, bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.only(left: 15.0),
                              decoration: BoxDecoration(
                                  color: Colors.brown.shade600.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: TextFormField(
                                controller: sheikhController,
                                cursorColor: Colors.white,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'name is required';
                                  } else if (value.length < 3) {
                                    return 'name must be at least 3 characters long';
                                  } else if (!isUsernameValid(value)) {
                                    return 'Enter a valid name \n (only letters, numbers, and underscores are allowed)';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.people,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    TKeys.sheikhName.translate(context),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  errorStyle:const TextStyle(color: Colors.white),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.white, width: 1.0),
                                  ),
                                  border: const UnderlineInputBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                                    borderSide:
                                    BorderSide(width: 1, color: Colors.white),
                                  ),
                                ),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                ),
                                onChanged: (value) {
                                  sheikhName = value;
                                },
                              ),
                            ),
                          ),
                          //phone number
                          Padding(
                            padding: EdgeInsets.only(left: width * .05, bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.only(left: 15.0),
                              decoration: BoxDecoration(
                                  color: Colors.brown.shade600.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: TextFormField(
                                controller: phoneController,
                                cursorColor: Colors.white,
                                keyboardType: TextInputType
                                    .phone, // Set keyboard type for phone number
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Allow only digits
                                  LengthLimitingTextInputFormatter(
                                      11), // Limit the length to 10 digits
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'phone number is required';
                                  } else if (!isPhoneValid(value)) {
                                    return 'Enter a valid phone number';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.phone,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    TKeys.phone.translate(context),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  errorStyle:const TextStyle(color: Colors.white),
                                  border: const UnderlineInputBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                                    borderSide:
                                    BorderSide(width: 1, color: Colors.white),
                                  ),
                                ),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20,),
                                onChanged: (value) {
                                  phone = value;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //area
                    Padding(
                      padding: EdgeInsets.only(left: width * .05, bottom: 10),
                      child: SizedBox(
                        height: 55,
                        child: PopupMenuButton<String>(
                          onSelected: (String value) async {
                            setState(() {
                              // Handle the selected value
                              area = value;
                              if (value == TKeys.other.translate(context)) {
                                areaOther = true;
                              } else {
                                areaStatus = area;
                                areaOther = false;
                              }
                            });
                            QuerySnapshot querySnapshot =
                            await FirebaseFirestore.instance
                                .collection('Cities')
                                .doc(area)
                                .collection('Mosques')
                                .get();
                            if (querySnapshot.docs.isNotEmpty) {
                              dataList = querySnapshot.docs
                                  .map((doc) => doc.id)
                                  .toSet();
                            } else {
                              dataList = {};
                            }
                          },
                          color: Colors.brown.shade600,
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
                                value: TKeys.other.translate(context),
                                child: Text(
                                  TKeys.other.translate(context),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                            return items;
                          },
                          offset: const Offset(0, 50),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.brown.shade600.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                  color: Colors.brown.shade400.withOpacity(.7),
                                  width: 2),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    area.isEmpty && !areaOther
                                        ? areaStatus
                                        : area.isNotEmpty? area :TKeys.other.translate(context),
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
                                  size: 35,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                        visible: areaOther,
                        child: Padding(
                          padding: EdgeInsets.only(left: width * .05, bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.only(left: 15.0),
                            decoration: BoxDecoration(
                                color: Colors.brown.shade600.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20.0)),
                            child: Form(
                              key: _formKey1,
                              child: TextFormField(
                                controller: areaController,
                                cursorColor: Colors.white,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'area is required';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.area_chart_outlined,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    TKeys.area.translate(context),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  errorStyle:const TextStyle(color: Colors.white),
                                  border: const UnderlineInputBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(20.0),),
                                    borderSide:
                                    BorderSide(width: 1, color: Colors.brown,),
                                  ),
                                ),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,),
                                onChanged: (value) {
                                  setState(() {
                                    area = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                    //mosque
                    Padding(
                      padding: EdgeInsets.only(left: width * .05, bottom: 10),
                      child: SizedBox(
                        height: 55,
                        child: PopupMenuButton<String>(
                          onSelected: (String value) {
                            setState(() {
                              // Handle the selected value
                              mosque = value;
                              if (value == TKeys.other.translate(context)) {
                                mosqueOther = true;
                              } else {
                                mosqueStatus = mosque;
                                mosqueOther = false;
                              }
                            });
                          },
                          color: Colors.brown.shade600,
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
                                value: TKeys.other.translate(context),
                                child: Text(
                                  TKeys.other.translate(context),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                            return items;
                          },
                          offset: const Offset(0, 50),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.brown.shade600.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                  color: Colors.brown.shade400.withOpacity(.7),
                                  width: 2),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    mosque.isEmpty && !mosqueOther
                                        ? mosqueStatus
                                        : mosque.isNotEmpty? mosque :TKeys.other.translate(context),
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
                                  size: 35,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: mosqueOther,
                      child: Form(
                        key: _formKey2,
                        child: Padding(
                          padding: EdgeInsets.only(left: width * .05, bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.only(left: 15.0),
                            decoration: BoxDecoration(
                                color: Colors.brown.shade600.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20.0)),
                            child: TextFormField(
                              controller: mosqueController,
                              cursorColor: Colors.white,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'mosque is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.mosque_outlined,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  TKeys.mosque.translate(context),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                errorStyle:const TextStyle(color: Colors.white),
                                border: const UnderlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(20.0),),
                                  borderSide:
                                  BorderSide(width: 1, color: Colors.brown,),
                                ),
                              ),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,),
                              onChanged: (value) {
                                setState(() {
                                  mosque = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      width: width*.8,
                      child: ElevatedButton(
                        onPressed: (){
                          getCurrentDateTime();
                          if(_formKey.currentState!.validate() && (area.isNotEmpty || areaOther) && (mosque.isNotEmpty || mosqueOther)){
                            if(areaOther && mosqueOther){
                              if (_formKey1.currentState!.validate() &&
                                  _formKey2.currentState!.validate()) {
                                validate();
                              }
                            }
                            else if(areaOther){
                              if (_formKey1.currentState!.validate()) {
                                validate();
                              }
                            }
                            else if (mosqueOther){
                              if (_formKey2.currentState!.validate()) {
                                validate();
                              }
                            }
                            else{
                              validate();
                            }
                          }
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill input')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.brown.shade400,
                            backgroundColor: Colors.brown,
                            disabledForegroundColor: Colors.brown.shade600,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                        child: Text(
                          TKeys.register.translate(context),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    getDocumentIDs();
  }
  void register() async{
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.name)
        .update({
      'sheikh name': sheikhName,
      'sheikh phone': phone,
      'time': '$formattedTime / $formattedDate',
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.name)
        .collection('Cities')
        .doc(area)
        .set({
      'mosque': mosque,
      'time': '$formattedTime / $formattedDate',
    });
    // if city isn't in the options
    //updating cities table
    await FirebaseFirestore.instance
        .collection('Cities')
        .doc(area)
        .collection('Mosques')
        .doc(mosque)
        .update({
      'sheikh name': sheikhName,
    });
    if(!(citiesIDs.contains(area))){
      await FirebaseFirestore.instance
          .collection('Cities')
          .doc(area)
          .set({
        'latitude': '',
        'longitude': '',
      });
    }
    //updating mosques table
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance
        .collection('Mosques')
        .where('mosque', isEqualTo: mosque)
        .where('city', isEqualTo: area)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('Mosques')
          .doc(querySnapshot.docs.first.id)
          .update({
        'connect time':
        '$formattedTime / $formattedDate',
        'sheikh name': sheikhName,
      });
    } else {
      await FirebaseFirestore.instance
          .collection('Mosques')
          .add({
        'mosque': mosque,
        'city': area,
        'connect time':
        '$formattedTime / $formattedDate',
        'sheikh name': sheikhName,
      });
    }
  }
  void validate() {
    try{
      //edit here
      register();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ScanningListScreen(
                userName: widget.name,
              )));
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('error is => $e');
      }
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                TKeys.problemOccurred.translate(context),
                style: const TextStyle(color: Colors.red),
              ),
            );
          });
    }
  }
}
