import 'dart:ui';

import 'package:azan/constants.dart';
import 'package:azan/t_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../functions.dart';

class AccountEdit extends StatefulWidget {
  const AccountEdit({super.key, required this.name});
  final String name;

  @override
  State<AccountEdit> createState() => _AccountEditState();
}

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
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

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
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 35,
          ),
        ),
        title: Text(
          TKeys.editProfile.translate(context),
          style: const TextStyle(
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
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                        errorStyle: TextStyle(color: Colors.white),
                                        border: UnderlineInputBorder(
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
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.phone,
                                          color: Colors.white,
                                        ),
                                        errorStyle: TextStyle(color: Colors.white),
                                        border: UnderlineInputBorder(
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
                                      keyboardType: TextInputType.emailAddress,
                                      cursorColor: Colors.white,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Email is required';
                                        } else if (!isEmailValid(value)) {
                                          return 'Enter a valid email address';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: Colors.white,
                                        ),
                                        errorStyle: TextStyle(color: Colors.white),
                                        border: UnderlineInputBorder(
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
                              ],
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
                                        style:
                                            const TextStyle(color: Colors.white),
                                      ),
                                      errorStyle: const TextStyle(color: Colors.white),
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
                                child: Form(
                                  key: _formKey2,
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
                                        style:
                                            const TextStyle(color: Colors.white),
                                      ),
                                      errorStyle: const TextStyle(color: Colors.white),
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
                          ),
                          //update users
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: width * .8,
                              child: ElevatedButton.icon(
                                onPressed: () async {
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
  @override
  void initState() {
    super.initState();
    userName = widget.name;
    updatedSheikhName = sheikhName;
    updatedSheikhNumber = sheikhPhone;
    updatedUserEmail = email;
    updatedArea = storedArea;
    updatedMosque = mosque;
    sheikhNameController = TextEditingController(text: sheikhName);
    sheikhNumberController = TextEditingController(text: sheikhPhone);
    userEmailController = TextEditingController(text: email);
    getMosquesList(storedArea);
  }
  void validate(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown.shade50,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.brown.shade700,
            ),
            const SizedBox(height: 16.0),
            Text(
              TKeys.updating.translate(context),
              style: TextStyle(
                  fontSize: 17,
                  color: Colors.brown.shade700),
            ),
          ],
        ),
      ),
    );
    if ((updatedSheikhName != sheikhName &&
        updatedSheikhName.isNotEmpty) ||
        (updatedSheikhNumber != sheikhPhone &&
            updatedSheikhNumber.isNotEmpty) ||
        (updatedUserEmail != email &&
            updatedUserEmail.isNotEmpty)) {
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
}
