import 'dart:ui';

import 'package:azan/t_key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ble/device_list.dart';
import '../constants.dart';
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
  List<String> options = [];
  late String sheikhName;
  late String phone;
  late String area = '';
  late String mosque = '';
  @override
  void initState() {
    super.initState();
    // getCurrentDateTime();
    getDocumentIDs();
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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
              padding: EdgeInsets.symmetric(horizontal: width*.07),
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
                            label: Text(TKeys.sheikhName.translate(context), style: const TextStyle(color: Colors.white),) ,
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
                          label: Text(TKeys.phone.translate(context),style: const TextStyle(color: Colors.white),),
                          error: Text('${validatePhoneNumber(phoneController.text)}',style: const TextStyle(color: Colors.white),),
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
                              area= value;
                              if(value == 'Other'){
                                areaOther = true;
                              }
                              else{
                                areaOther = false;
                              }
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
                              color: Colors.brown.shade800.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(color: Colors.brown.shade400.withOpacity(.7), width: 2),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    area ==''? TKeys.selectArea.translate(context): area,
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
                    Visibility(
                      visible: areaOther,
                      child: Padding(
                        padding: EdgeInsets.only(left: width * .05,bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.only(left: 15.0),
                          decoration: BoxDecoration(color: Colors.brown.shade800.withOpacity(0.7),borderRadius: BorderRadius.circular(20.0)),
                          child: TextFormField(
                            controller: areaController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.area_chart_outlined,color: Colors.white,),
                              label: Text(TKeys.area.translate(context),style: const TextStyle(color: Colors.white),),
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
                                area = value;
                              });
                            },
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
                              mosque = value;
                              if(value == 'Other'){
                                mosqueOther = true;
                              }
                              else{
                                mosqueOther = false;
                              }
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
                              color: Colors.brown.shade800.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(color: Colors.brown.shade400.withOpacity(.7), width: 2),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    mosque ==''? TKeys.selectMosque.translate(context): mosque,
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
                    Visibility(
                      visible: mosqueOther,
                      child: Padding(
                        padding: EdgeInsets.only(left: width * .05,bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.only(left: 15.0),
                          decoration: BoxDecoration(color: Colors.brown.shade800.withOpacity(0.7),borderRadius: BorderRadius.circular(20.0)),
                          child: TextFormField(
                            controller: mosqueController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.mosque_outlined, color: Colors.white,),
                              label: Text(TKeys.mosque.translate(context),style: const TextStyle(color: Colors.white),),
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
                                mosque = value;
                              });
                            },
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
                              if(!area.endsWith(name)){
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
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Text(
                                      TKeys.problemOccurred.translate(context),
                                      style: const TextStyle(
                                          color: Colors.red
                                      ),
                                    ),
                                  );
                                }
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.brown.shade400,
                            backgroundColor: Colors.brown,
                            disabledForegroundColor: Colors.brown.shade600,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        child: Text(TKeys.register.translate(context),style: const TextStyle(color: Colors.white, fontSize: 24),),
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
}
