import 'dart:ui';

import 'package:azan/account/edit_details.dart';
import 'package:azan/functions.dart';
import 'package:azan/t_key.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class AccountDetails extends StatefulWidget {
  const AccountDetails({super.key, required this.name});
  final String name;

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.brown.shade800,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context,true);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 35,),
        ),
        title: Text(TKeys.accountDetails.translate(context),style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20,),),
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width*.1, vertical: 15),
            child: Center(
              child: RefreshIndicator(
                onRefresh: () => Future.delayed(const Duration(milliseconds: 10), (){
                  accFlag = false;
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AccountDetails(name: widget.name)));
                }),
                child: ListView(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
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
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(TKeys.hello.translate(context), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown.shade700),),
                                  Text(widget.name, style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.brown.shade700),),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: (){
                              Navigator.push(context,MaterialPageRoute(settings: const RouteSettings(name: "/Page1"),builder: (context)=>AccountEdit(name: widget.name,)));
                            },
                            icon: Icon(Icons.edit_outlined,color: Colors.brown.shade800,size: 30,),
                          ),
                        ],
                      ),
                    ),
                    Text(TKeys.sheikhName.translate(context),style: TextStyle(fontSize:20,color: Colors.brown.shade700,),),
                    Padding(
                      padding: EdgeInsets.only(left: width * .05,bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        decoration: BoxDecoration(color: Colors.brown.shade800.withOpacity(0.7),borderRadius: BorderRadius.circular(20.0)),
                        child: TextFormField(
                          enabled: false,
                          decoration: InputDecoration(
                            label: Text(sheikhName,style: const TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
                            border: const UnderlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(width: 1, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(TKeys.email.translate(context),style: TextStyle(fontSize:20,color: Colors.brown.shade700,),),
                    Padding(
                      padding: EdgeInsets.only(left: width * .05,bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        decoration: BoxDecoration(color: Colors.brown.shade800.withOpacity(0.7),borderRadius: BorderRadius.circular(20.0)),
                        child: TextFormField(
                          enabled: false,
                          decoration: InputDecoration(
                            label: Text(email,style: const TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
                            border: const UnderlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(width: 1, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(TKeys.phone.translate(context),style: TextStyle(fontSize:20,color: Colors.brown.shade700,),),
                    Padding(
                      padding: EdgeInsets.only(left: width * .05,bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        decoration: BoxDecoration(color: Colors.brown.shade800.withOpacity(0.7),borderRadius: BorderRadius.circular(20.0)),
                        child: TextFormField(
                          enabled: false,
                          decoration: InputDecoration(
                            label: Text(sheikhPhone,style: const TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
                            border: const UnderlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(width: 1, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(TKeys.area.translate(context),style: TextStyle(fontSize:20,color: Colors.brown.shade700,),),
                    Padding(
                      padding: EdgeInsets.only(left: width * .05,bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        decoration: BoxDecoration(color: Colors.brown.shade800.withOpacity(0.7),borderRadius: BorderRadius.circular(20.0)),
                        child: TextFormField(
                          enabled: false,
                          decoration: InputDecoration(
                            label: Text(storedArea,style: const TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
                            border: const UnderlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(width: 1, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(TKeys.mosque.translate(context),style: TextStyle(fontSize:20,color: Colors.brown.shade700,),),
                    Padding(
                      padding: EdgeInsets.only(left: width * .05,bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        decoration: BoxDecoration(color: Colors.brown.shade800.withOpacity(0.7),borderRadius: BorderRadius.circular(20.0)),
                        child: TextFormField(
                          enabled: false,
                          decoration: InputDecoration(
                            label: Text(mosque,style: const TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
                            border: const UnderlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(width: 1, color: Colors.black),
                            ),
                          ),
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
  void initState(){
    super.initState();
    setState(() {
      if(!accFlag){ // add condition if updated
        showToastMessage();
        getUserFields(widget.name);
      }
    });
  }
}
