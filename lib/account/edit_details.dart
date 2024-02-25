import 'dart:ui';

import 'package:azan/constants.dart';
import 'package:azan/t_key.dart';
import 'package:flutter/material.dart';

import '../functions.dart';

class AccountEdit extends StatefulWidget {
  const AccountEdit({super.key, required this.name});
  final String name;

  @override
  State<AccountEdit> createState() => _AccountEditState();
}

// var userNameController = TextEditingController();
var sheikhNameController = TextEditingController();
var sheikhNumberController = TextEditingController();
var userEmailController = TextEditingController();
final mosqueController = TextEditingController();
final areaController = TextEditingController();
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
    updatedSheikhName = sheikhName;
    updatedSheikhNumber = sheikhPhone;
    updatedUserEmail = email;
    updatedArea = storedArea;
    updatedMosque = mosque;
    // userNameController = TextEditingController(text: widget.name);
    sheikhNameController = TextEditingController(text: sheikhName);
    sheikhNumberController = TextEditingController(text: sheikhPhone);
    userEmailController = TextEditingController(text: email);
    // mosqueController =
    //     TextEditingController(text: mosque);
    // areaController =
    //     TextEditingController(text: area);
    // getDocumentIDs();
    getMosquesList(storedArea);
  }

  @override
  void dispose() {
    // userConfirm = false;
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
            Navigator.pop(context);
            // Navigator.of(context)
            //     .popUntil(ModalRoute.withName("/Page1"));
            // userConfirm = false;
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 35,
          ),
        ),
        title: Text(
          TKeys.editProfile.translate(context),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
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
                  padding: EdgeInsets.symmetric(
                      horizontal: width * .07, vertical: 15.0),
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
                          // sheikh name
                          Text(
                            TKeys.sheikhName.translate(context),
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.brown.shade700,
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: width * .05, bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.only(left: 15.0),
                              decoration: BoxDecoration(
                                  color: Colors.brown.shade800.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: TextFormField(
                                controller: sheikhNameController,
                                cursorColor: Colors.brown,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return TKeys.validator.translate(context);
                                  return null;
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                  // hintText: 'Sheikh Name',
                                  floatingLabelStyle:
                                      MaterialStateTextStyle.resolveWith(
                                          (Set<MaterialState> states) {
                                    final Color color = states
                                            .contains(MaterialState.error)
                                        ? Theme.of(context).colorScheme.error
                                        : Colors.brown.shade900;
                                    return TextStyle(
                                        color: color, letterSpacing: 1.3);
                                  }),
                                  labelStyle:
                                      MaterialStateTextStyle.resolveWith(
                                          (Set<MaterialState> states) {
                                    final Color color = states
                                            .contains(MaterialState.error)
                                        ? Theme.of(context).colorScheme.error
                                        : Colors.brown.shade800;
                                    return TextStyle(
                                        color: color, letterSpacing: 1.3);
                                  }),
                                  border: const UnderlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.black),
                                  ),
                                ),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                                onChanged: (value) async {
                                  setState(() {
                                    updatedSheikhName = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          //sheikh number
                          Text(
                            TKeys.phone.translate(context),
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.brown.shade700,
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: width * .05, bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.only(left: 15.0),
                              decoration: BoxDecoration(
                                  color: Colors.brown.shade800.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: TextFormField(
                                controller: sheikhNumberController,
                                cursorColor: Colors.brown,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return TKeys.validator.translate(context);
                                  return null;
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.phone,
                                    color: Colors.white,
                                  ),
                                  // hintText: 'Sheikh Number',
                                  floatingLabelStyle:
                                      MaterialStateTextStyle.resolveWith(
                                          (Set<MaterialState> states) {
                                    final Color color = states
                                            .contains(MaterialState.error)
                                        ? Theme.of(context).colorScheme.error
                                        : Colors.brown.shade900;
                                    return TextStyle(
                                        color: color, letterSpacing: 1.3);
                                  }),
                                  labelStyle:
                                      MaterialStateTextStyle.resolveWith(
                                          (Set<MaterialState> states) {
                                    final Color color = states
                                            .contains(MaterialState.error)
                                        ? Theme.of(context).colorScheme.error
                                        : Colors.brown.shade800;
                                    return TextStyle(
                                        color: color, letterSpacing: 1.3);
                                  }),
                                  border: const UnderlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.black),
                                  ),
                                ),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                                onChanged: (value) async {
                                  setState(() {
                                    updatedSheikhNumber = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          //email
                          Text(
                            TKeys.email.translate(context),
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.brown.shade700,
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: width * .05, bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.only(left: 15.0),
                              decoration: BoxDecoration(
                                  color: Colors.brown.shade800.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: TextFormField(
                                controller: userEmailController,
                                cursorColor: Colors.brown,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return TKeys.validator.translate(context);
                                  return null;
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: Colors.white,
                                  ),
                                  // hintText: 'Email',
                                  floatingLabelStyle:
                                      MaterialStateTextStyle.resolveWith(
                                          (Set<MaterialState> states) {
                                    final Color color = states
                                            .contains(MaterialState.error)
                                        ? Theme.of(context).colorScheme.error
                                        : Colors.brown.shade900;
                                    return TextStyle(
                                        color: color, letterSpacing: 1.3);
                                  }),
                                  labelStyle:
                                      MaterialStateTextStyle.resolveWith(
                                          (Set<MaterialState> states) {
                                    final Color color = states
                                            .contains(MaterialState.error)
                                        ? Theme.of(context).colorScheme.error
                                        : Colors.brown.shade800;
                                    return TextStyle(
                                        color: color, letterSpacing: 1.3);
                                  }),
                                  border: const UnderlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.black),
                                  ),
                                ),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                                onChanged: (value) async {
                                  setState(() {
                                    updatedUserEmail = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          //area
                          Text(
                            TKeys.area.translate(context),
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.brown.shade700,
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: width * .05, bottom: 10),
                            child: SizedBox(
                              height: 55,
                              child: PopupMenuButton<String>(
                                onSelected: (String value) {
                                  setState(() {
                                    // Handle the selected value
                                    updatedArea = value;
                                    getMosquesList(value);
                                    if (value ==
                                        TKeys.other.translate(context)) {
                                      areaOther = true;
                                    } else {
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
                                      value: TKeys.other.translate(context),
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
                                    color:
                                        Colors.brown.shade800.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                        color: Colors.brown.shade400
                                            .withOpacity(.7),
                                        width: 2),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          areaOther
                                              ? TKeys.other.translate(context)
                                              : updatedArea,
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
                              padding: EdgeInsets.only(
                                  left: width * .05, bottom: 10),
                              child: Container(
                                padding: const EdgeInsets.only(left: 15.0),
                                decoration: BoxDecoration(
                                    color:
                                        Colors.brown.shade800.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: TextFormField(
                                  controller: areaController,
                                  cursorColor: Colors.brown,
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return TKeys.validator.translate(context);
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.area_chart_outlined,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      TKeys.area.translate(context),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    floatingLabelStyle:
                                        MaterialStateTextStyle.resolveWith(
                                            (Set<MaterialState> states) {
                                      final Color color = states
                                              .contains(MaterialState.error)
                                          ? Theme.of(context).colorScheme.error
                                          : Colors.brown.shade900;
                                      return TextStyle(
                                          color: color, letterSpacing: 1.3);
                                    }),
                                    labelStyle:
                                        MaterialStateTextStyle.resolveWith(
                                            (Set<MaterialState> states) {
                                      final Color color = states
                                              .contains(MaterialState.error)
                                          ? Theme.of(context).colorScheme.error
                                          : Colors.brown.shade800;
                                      return TextStyle(
                                          color: color, letterSpacing: 1.3);
                                    }),
                                    border: const UnderlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.brown),
                                    ),
                                  ),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  onChanged: (value) {
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
                          Text(
                            TKeys.mosque.translate(context),
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.brown.shade700,
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: width * .05, bottom: 10),
                            child: SizedBox(
                              height: 55,
                              child: PopupMenuButton<String>(
                                onSelected: (String value) {
                                  setState(() {
                                    // Handle the selected value
                                    updatedMosque = value;
                                    if (value ==
                                        TKeys.other.translate(context)) {
                                      mosqueOther = true;
                                    } else {
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
                                      value: TKeys.other.translate(context),
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
                                    color:
                                        Colors.brown.shade800.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                        color: Colors.brown.shade400
                                            .withOpacity(.7),
                                        width: 2),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          mosqueOther
                                              ? TKeys.other.translate(context)
                                              : updatedMosque,
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
                              padding: EdgeInsets.only(
                                  left: width * .05, bottom: 10),
                              child: Container(
                                padding: const EdgeInsets.only(left: 15.0),
                                decoration: BoxDecoration(
                                    color:
                                        Colors.brown.shade800.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: TextFormField(
                                  controller: mosqueController,
                                  cursorColor: Colors.brown,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return TKeys.validator.translate(context);
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
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    floatingLabelStyle:
                                        MaterialStateTextStyle.resolveWith(
                                            (Set<MaterialState> states) {
                                      final Color color = states
                                              .contains(MaterialState.error)
                                          ? Theme.of(context).colorScheme.error
                                          : Colors.brown.shade900;
                                      return TextStyle(
                                          color: color, letterSpacing: 1.3);
                                    }),
                                    labelStyle:
                                        MaterialStateTextStyle.resolveWith(
                                            (Set<MaterialState> states) {
                                      final Color color = states
                                              .contains(MaterialState.error)
                                          ? Theme.of(context).colorScheme.error
                                          : Colors.brown.shade800;
                                      return TextStyle(
                                          color: color, letterSpacing: 1.3);
                                    }),
                                    border: const UnderlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.brown),
                                    ),
                                  ),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  onChanged: (value) {
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
                              width: width * .8,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Colors.brown.shade50,
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(color: Colors.brown.shade700,),
                                          const SizedBox(height: 16.0),
                                          Text(TKeys.updating.translate(context), style: TextStyle(fontSize: 17,color: Colors.brown.shade700),),
                                        ],
                                      ),
                                    ),
                                  );
                                  if (updatedSheikhName == sheikhName &&
                                      updatedSheikhNumber == sheikhPhone &&
                                      updatedUserEmail == email &&
                                      updatedArea == area &&
                                      updatedMosque == mosque) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: Text(
                                              TKeys.updateError
                                                  .translate(context),
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        });
                                  }
                                  else {
                                    if ((updatedSheikhName != sheikhName &&
                                            updatedSheikhName.isNotEmpty) ||
                                        (updatedSheikhNumber != sheikhPhone &&
                                            updatedSheikhNumber.isNotEmpty) ||
                                        (updatedUserEmail != email &&
                                            updatedUserEmail.isNotEmpty)) {
                                      print('before editing user field');
                                      updateUserData(userName);
                                    }
                                    if (updatedArea != area &&
                                        updatedArea.isNotEmpty) {
                                      if (updatedMosque != mosque &&
                                          updatedMosque.isNotEmpty) {
                                        //case mosque and city updated
                                        updateMosques(userName, 2);
                                        updateUserColl(userName, 2);
                                        updateCitiesAndMosques();
                                      } else {
                                        //case only city is updated
                                        updateMosques(userName, 1);
                                        updateUserColl(userName, 1);
                                        updateCitiesAndMosques();
                                      }
                                    }
                                    else if (updatedMosque != mosque &&
                                        updatedMosque.isNotEmpty) {
                                      //case only mosque is updated
                                      updateMosques(userName, 0);
                                      updateUserColl(userName, 0);
                                      updateCitiesAndMosques();
                                    }
                                    setState(() {
                                      accFlag = false;
                                    });
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.brown.shade400,
                                    backgroundColor: Colors.brown,
                                    disabledForegroundColor:
                                        Colors.brown.shade600,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                icon: const Icon(
                                  Icons.update,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  TKeys.update.translate(context),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
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
