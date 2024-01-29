import 'dart:ui';

import 'package:azan/constants.dart';
import 'package:azan/t_key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../functions.dart';
import 'account_details.dart';

class AccountEdit extends StatefulWidget {
  const AccountEdit({super.key, required this.name});
  final String name;

  @override
  State<AccountEdit> createState() => _AccountEditState();
}
var userNameController = TextEditingController();
var sheikhNameController = TextEditingController();
var sheikhNumberController = TextEditingController();
var userEmailController = TextEditingController();
// var mosqueController = TextEditingController();
// var areaController = TextEditingController();
String userName = '';
String updatedSheikhName = '';
String updatedSheikhNumber = '';
String updatedUserEmail = '';
String updatedArea = '';
String updatedMosque = '';
class _AccountEditState extends State<AccountEdit> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userName = widget.name;
    updatedSheikhName=sheikhName;
    updatedSheikhNumber=sheikhPhone;
    updatedUserEmail =email;
    updatedArea = storedArea;
    updatedMosque = mosque;
    userNameController =
        TextEditingController(text: widget.name);
    sheikhNameController =
        TextEditingController(text: sheikhName);
    sheikhNumberController =
        TextEditingController(text: sheikhPhone);
    userEmailController =
        TextEditingController(text: email);
    // mosqueController =
    //     TextEditingController(text: mosque);
    // areaController =
    //     TextEditingController(text: area);
    // getDocumentIDs();
    getMosquesList(storedArea);
  }
  @override
  void dispose(){
    userConfirm = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          backgroundColor: Colors.brown.shade800,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>AccountDetails(name: userName,)));
            userConfirm = false;
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 35,),
        ),
        title: Text(TKeys.editProfile.translate(context),style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20,),),
        centerTitle: true,
      ),
        body: Stack(
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
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
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width*.07, vertical: 15.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //letter photo
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.brown.shade700,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    initial,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          //username
                          Text(TKeys.userName.translate(context),style: TextStyle(fontSize:20,color: Colors.brown.shade700,),),
                          Padding(
                            padding: EdgeInsets.only(left: width * .05,bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.only(left: 15.0),
                              decoration: BoxDecoration(color: Colors.brown.shade800.withOpacity(0.7),borderRadius: BorderRadius.circular(20.0)),
                              child: TextFormField(
                                controller: userNameController,
                                cursorColor: Colors.brown,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.supervised_user_circle_outlined, color: Colors.white,),
                                  // hintText: 'Username',
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
                                onChanged: (value)async{
                                  setState(() {
                                    userName = value;
                                  });
                              },
                              ),
                            ),
                          ),
                          Visibility(visible:userConfirm ,child: Text(TKeys.userNameError.translate(context),style: const TextStyle(color: Colors.red),)),
                          //sheikh name
                          Text(TKeys.sheikhName.translate(context),style: TextStyle(fontSize:20,color: Colors.brown.shade700,),),
                          Padding(
                            padding: EdgeInsets.only(left: width * .05,bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.only(left: 15.0),
                              decoration: BoxDecoration(color: Colors.brown.shade800.withOpacity(0.7),borderRadius: BorderRadius.circular(20.0)),
                              child: TextFormField(
                                controller: sheikhNameController,
                                cursorColor: Colors.brown,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.person, color: Colors.white,),
                                  // hintText: 'Sheikh Name',
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
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                onChanged: (value)async{
                                  setState(() {
                                    updatedSheikhName = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          //sheikh number
                          Text(TKeys.phone.translate(context),style: TextStyle(fontSize:20,color: Colors.brown.shade700,),),
                          Padding(
                            padding: EdgeInsets.only(left: width * .05,bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.only(left: 15.0),
                              decoration: BoxDecoration(color: Colors.brown.shade800.withOpacity(0.7),borderRadius: BorderRadius.circular(20.0)),
                              child: TextFormField(
                                controller: sheikhNumberController,
                                cursorColor: Colors.brown,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.phone,color: Colors.white,),
                                  // hintText: 'Sheikh Number',
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
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                onChanged: (value)async{
                                  setState(() {
                                    updatedSheikhNumber = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          //email
                          Text(TKeys.email.translate(context),style: TextStyle(fontSize:20,color: Colors.brown.shade700,),),
                          Padding(
                            padding: EdgeInsets.only(left: width * .05,bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.only(left: 15.0),
                              decoration: BoxDecoration(color: Colors.brown.shade800.withOpacity(0.7),borderRadius: BorderRadius.circular(20.0)),
                              child: TextFormField(
                                controller: userEmailController,
                                cursorColor: Colors.brown,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.white,),
                                  // hintText: 'Email',
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
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                onChanged: (value)async{
                                  setState(() {
                                    updatedUserEmail = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          //area
                          Text(TKeys.area.translate(context),style: TextStyle(fontSize:20,color: Colors.brown.shade700,),),
                          Padding(
                            padding: EdgeInsets.only(left: width * .05,bottom: 10),
                            child: SizedBox(
                              height: 55,
                              child: PopupMenuButton<String>(
                                onSelected: (String value) {
                                  setState(() {
                                    // Handle the selected value
                                    updatedArea = value;
                                    getMosquesList(value);
                                    if(value == 'Other'){
                                      areaOther = true;
                                    }
                                    else{
                                      areaOther = false;
                                    }
                                  });
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
                                      child: SizedBox(
                                        width: 200,
                                        child: Text(
                                          TKeys.other.translate(context),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
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
                                          updatedArea,
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
                                  controller: TextEditingController(),
                                  cursorColor: Colors.brown,
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
                                      updatedArea = value;
                                      getMosquesList(value);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          //mosque
                          Text(TKeys.mosque.translate(context),style: TextStyle(fontSize:20,color: Colors.brown.shade700,),),
                          Padding(
                            padding: EdgeInsets.only(left: width * .05,bottom: 10),
                            child: SizedBox(
                              height: 55,
                              child: PopupMenuButton<String>(
                                onSelected: (String value) {
                                  setState(() {
                                    // Handle the selected value
                                    updatedMosque = value;
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
                                    if (item != mosquesIDs.last) {
                                      items.add(const PopupMenuDivider());
                                    }
                                  }
                                  items.add(
                                    PopupMenuItem<String>(
                                      value: 'Other',
                                      child: SizedBox(
                                        width: 200,
                                        child: Text(
                                          TKeys.other.translate(context),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
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
                                          updatedMosque,
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
                            child: Padding(
                              padding: EdgeInsets.only(left: width * .05,bottom: 10),
                              child: Container(
                                padding: const EdgeInsets.only(left: 15.0),
                                decoration: BoxDecoration(color: Colors.brown.shade800.withOpacity(0.7),borderRadius: BorderRadius.circular(20.0)),
                                child: TextFormField(
                                  controller: TextEditingController(),
                                  cursorColor: Colors.brown,
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
                                      updatedMosque = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          //update users
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: width*.8,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  //show alert dialog if no data is updated
                                  if(widget.name != userName || updatedSheikhName != sheikhName || updatedSheikhNumber != sheikhPhone || updatedUserEmail != email || updatedArea != storedArea || updatedMosque != mosque){
                                    //something is updated
                                    //update the data in firebase
                                    if (widget.name != null) {
                                      //if username is in use
                                      try {
                                        //update users fields (case: name is updated) in users collection
                                        if(widget.name != userName){
                                          for(String name in usersIDs){
                                            if(name.endsWith(userName)){
                                              setState(() {
                                                userConfirm = true;
                                              });
                                              break;
                                            }
                                            else{
                                              firestore.collection('users').doc(widget.name).delete().then((value) {
                                                // Check if the document is deleted successfully
                                                firestore.collection('users').doc(widget.name).get().then((doc) {
                                                  //check if deletion is successful and then save the data
                                                  if (!doc.exists) {
                                                    // Document is deleted, proceed with the set operation
                                                    //password missed
                                                    firestore.collection('users').doc(userName).set({
                                                      'sheikh name': updatedSheikhName,
                                                      'sheikh phone': updatedSheikhNumber,
                                                      'user email': updatedUserEmail,
                                                      'time': getCurrentDateTime(),
                                                      'note': 'edited data',
                                                    }).then((_) {
                                                      // Set operation completed
                                                      print('Document set operation completed.');
                                                    }).catchError((error) {
                                                      // Handle errors in the set operation
                                                      print('Error setting document: $error');
                                                    });
                                                  }
                                                  //if not show an alertdialog
                                                  else {
                                                    // Document still exists, deletion might not have been successful
                                                    print('Document deletion unsuccessful.');
                                                  }
                                                });
                                              }).catchError((error) {
                                                // Handle errors in the deletion operation
                                                print('Error deleting document: $error');
                                              });
                                            }
                                          }
                                        }
                                        //if username isn't updated but other data (sheikh name || sheikh number || email)
                                        else{
                                          //update users (case: sheikh name || sheikh number || email is updated)
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(userName)
                                              .update({
                                            'sheikh name': updatedSheikhName,
                                            'sheikh phone': updatedSheikhNumber,
                                            'user email': updatedUserEmail,
                                            'time': getCurrentDateTime(),
                                            'note': 'edited data',
                                          });
                                        }
                                        // update cities and mosques in Cities collection
                                        if(updatedArea != storedArea && updatedArea.isNotEmpty){
                                          //check if the city is in the database
                                          if(citiesIDs.contains(updatedArea)){
                                            //if mosque is in city
                                            for(String mosque in dataList){
                                              if (mosque.endsWith(updatedMosque)){
                                                //update sheikhname
                                                if(updatedSheikhName != sheikhName){
                                                  FirebaseFirestore.instance.collection('Cities').doc(updatedArea).collection('Mosques').doc(updatedMosque).update(
                                                      {'sheikh name':updatedSheikhName,});
                                                }
                                                mosqueFound = true;
                                              }
                                            }
                                            if(!mosqueFound){
                                              FirebaseFirestore.instance.collection('Cities').doc(updatedArea).collection('Mosques').doc(updatedMosque).set(
                                                  {'sheikh name':updatedSheikhName,});
                                            }
                                          }
                                          //add the city and add the mosque
                                          else{
                                            ///check if longitude and latitude will be inserted manually
                                            FirebaseFirestore.instance.collection('Cities').doc(updatedArea).collection('Mosques').doc(updatedMosque).set(
                                                {'sheikh name':updatedSheikhName,});
                                          }
                                        }
                                        //update mosques
                                        if(updatedMosque != mosque && updatedMosque.isNotEmpty){
                                          //reset sheikh name in previous mosque
                                          final printingData = await FirebaseFirestore.instance.collection('Mosques').where('mosque',isEqualTo:mosque).where('city',isEqualTo: updatedArea).get();
                                          //reset sheikh name
                                          if(printingData.docs.isNotEmpty){
                                            // printingData.docs.forEach((doc) async{
                                              try{
                                                DocumentReference docRef = FirebaseFirestore.instance.collection('Mosques').doc(printingData.docs.first.id);
                                                await docRef.update({
                                                  'sheikh name': '',
                                                  'connect time': getCurrentDateTime(),
                                                });
                                              }
                                              catch(e){
                                                print('got a problem $e');
                                              }
                                            // });
                                          }
                                          //if new mosque is in the database => update the sheikh name in mosque
                                          final inDatabase = await FirebaseFirestore.instance.collection('Mosques').where('mosque',isEqualTo: updatedMosque).where('city',isEqualTo: updatedArea).get();
                                          if(inDatabase.docs.isNotEmpty){
                                            // inDatabase.docs.forEach((doc)async{
                                              try{
                                                DocumentReference docRef = FirebaseFirestore.instance.collection('Mosques').doc(inDatabase.docs.first.id);
                                                await docRef.update({
                                                  'sheikh name': updatedSheikhName,
                                                  'connect time':getCurrentDateTime(),
                                                });
                                              }
                                              catch(e){
                                                print('got a problem $e');
                                              }
                                            // });
                                          }
                                          //else if the new mosque isn't fount in the database
                                          else{
                                            FirebaseFirestore.instance.collection('Mosques').add({
                                              'city':updatedArea,
                                              'connect time':getCurrentDateTime(),
                                              'mosque':updatedMosque,
                                              'sheikh name':updatedSheikhName,
                                            });
                                          }
                                          //update cities and mosques in users
                                          if(storedArea != updatedArea && updatedArea.isNotEmpty){
                                            if(mosque != updatedMosque && updatedMosque.isNotEmpty){
                                              FirebaseFirestore.instance.collection('users').doc(userName).collection('Cities').doc(storedArea).delete().then((value) => FirebaseFirestore.instance.collection('users').doc(userName).collection('Cities').doc(updatedArea).set(
                                                  {'mosque':updatedMosque,})).catchError((error) {
                                                // Handle errors in the deletion operation
                                                print('Error deleting document: $error');
                                              });
                                            }
                                            else{
                                              DocumentSnapshot currentDocSnapshot = await FirebaseFirestore.instance.collection('users').doc(userName).collection('Cities').doc(storedArea).get();
                                              // Check if the current document exists
                                              if (currentDocSnapshot.exists) {
                                                // Get the data from the current document
                                                Map<String, dynamic> data = currentDocSnapshot.data() as Map<String, dynamic>;

                                                // Create a new document with the new ID and set the data
                                                await FirebaseFirestore.instance.collection('users').doc(userName).collection('Cities').doc(updatedArea).set(data);

                                                // Optionally, delete the old document
                                                await FirebaseFirestore.instance.collection('users').doc(userName).collection('Cities').doc(storedArea).delete();

                                              }
                                            }
                                          }
                                          else{
                                            if(mosque != updatedMosque && updatedMosque.isNotEmpty){
                                              // FirebaseFirestore.instance.collection('users').doc(userNameController.text).collection('Cities').doc(area).delete().then((value) => );
                                              FirebaseFirestore.instance.collection('users').doc(userName).collection('Cities').doc(updatedArea).update(
                                                  {'mosque':updatedMosque,});
                                            }
                                          }
                                        }
                                        print('Done');
                                        //should navigate only if data is updated //move its location in code and think if i should navigate to
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AccountDetails(
                                              name: widget.name,
                                            ),
                                          ),
                                          // (route) => false,
                                        );
                                      } catch (e) {
                                        print(e);
                                      }
                                    }
                                  }
                                  else{
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(TKeys.error.translate(context)),
                                          content: Text(TKeys.updateError.translate(context)),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: Text(TKeys.ok.translate(context)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.brown.shade400,
                                  backgroundColor: Colors.brown,
                                  disabledForegroundColor: Colors.brown.shade600,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                icon: const Icon(Icons.update, color: Colors.white,),
                                label: Text(TKeys.update.translate(context),style: const TextStyle(color: Colors.white, fontSize: 24),),
                              ),
                            ),
                          ),
                      ]
                      ),
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
