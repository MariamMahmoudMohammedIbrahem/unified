import 'package:azan/constants.dart';
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
var mosqueController = TextEditingController();
var areaController = TextEditingController();
class _AccountEditState extends State<AccountEdit> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userNameController =
        TextEditingController(text: widget.name);
    sheikhNameController =
        TextEditingController(text: sheikhName);
    sheikhNumberController =
        TextEditingController(text: sheikhPhone);
    userEmailController =
        TextEditingController(text: email);
    mosqueController =
        TextEditingController(text: mosque);
    areaController =
        TextEditingController(text: area);
    getDocumentIDs();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(context,MaterialPageRoute(builder: (context)=>AccountDetails(name: userNameController.text,)));
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.07),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //letter photo
            Container(
              width: 100,
              height: 100,
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
                    fontSize: 40,
                  ),
                ),
              ),
            ),
            //username
            const Text('Username'),
            TextFormField(
              controller: userNameController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.supervised_user_circle_outlined),
                hintText: 'Username',
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
            const SizedBox(height: 10,),
            //sheikh name
            const Text('Sheikh Name'),
            TextFormField(
              controller: sheikhNameController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person),
                hintText: 'Sheikh Name',
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
            const SizedBox(height: 10,),
            //sheikh number
            const Text('Sheikh Number'),
            TextFormField(
              controller: sheikhNumberController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone),
                hintText: 'Sheikh Number',
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
            const SizedBox(height: 10,),
            //email
            const Text('Email'),
            TextFormField(
              controller: userEmailController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_outlined),
                hintText: 'Email',
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
            const SizedBox(height: 10,),
            //area
            const Text('Area'),
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
                                controller: TextEditingController(),
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
                                    areaController.text = value;
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
                            areaController.text,
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
            const SizedBox(height: 10,),
            //mosque
            const Text('Mosque'),
            Flexible(
              child: SizedBox(
                height: 55,
                child: PopupMenuButton<String>(
                  onSelected: (String value) {
                    setState(() {
                      // Handle the selected value
                      mosqueController.text = value;
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
                                controller: TextEditingController(),
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
                                    mosqueController.text = value;
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
                            mosqueController.text,
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
            const SizedBox(height: 10,),
            //update users
            ElevatedButton(
                onPressed: () async {
                  //update the data in firebase
                  if (widget.name != null) {
                    //if username is in use
                    try {
                      //update users fields
                      if(widget.name != userNameController.text){
                        for(String name in usersIDs){
                          if(name.endsWith(userNameController.text)){
                            setState(() {
                              userConfirm = true;
                            });
                            break;
                          }else{
                            firestore.collection('users').doc(widget.name).delete().then((value) {
                              // Check if the document is deleted successfully
                              firestore.collection('users').doc(widget.name).get().then((doc) {
                                if (!doc.exists) {
                                  // Document is deleted, proceed with the set operation
                                  //password missed
                                  firestore.collection('users').doc(userNameController.text).set({
                                    'sheikh name': sheikhNameController.text,
                                    'sheikh phone': sheikhNumberController.text,
                                    'user email': userEmailController.text,
                                    'time': getCurrentDateTime(),
                                    'note': 'edited data',
                                    'password':'',
                                  }).then((_) {
                                    // Set operation completed
                                    print('Document set operation completed.');
                                  }).catchError((error) {
                                    // Handle errors in the set operation
                                    print('Error setting document: $error');
                                  });
                                } else {
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
                      else{
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userNameController.text)
                            .update({
                          'sheikh name': sheikhNameController.text,
                          'sheikh phone': sheikhNumberController.text,
                          'user email': userEmailController.text,
                          'time': getCurrentDateTime(),
                          'note': 'edited data',
                        });
                      }
                      print('Done');
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>AccountEdit(name: userNameController.text,)));
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                child: const Text('Update',),
            ),
            ElevatedButton(onPressed: (){}, child: Text('update cities'),),
            ElevatedButton(onPressed: (){}, child: Text('update mosques in cities'),),
            ElevatedButton(onPressed: (){}, child: Text('update mosques'),),
        ]
        ),
      ));
  }
}
