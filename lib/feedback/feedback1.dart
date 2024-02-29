import 'package:azan/constants.dart';
import 'package:azan/t_key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FeedbackRegister extends StatefulWidget {
  const FeedbackRegister({
    Key? key,
    required this.name,
  }) : super(key: key);
  final String name;

  @override
  State<FeedbackRegister> createState() => _FeedbackRegisterState();
}

class _FeedbackRegisterState extends State<FeedbackRegister> {
  final controllerNote = TextEditingController();
  late String selectedOption = '';
  late String msg = '';
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.brown.shade800,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context,true);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: Text(
          TKeys.complain.translate(context),
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SizedBox(
            width: width,
            child: Image.asset('images/feedback.jpg'),
          ),
          // options
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * .07),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TKeys.help.translate(context),
                  style: TextStyle(
                      color: Colors.brown.shade700,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Radio(
                            value: 'Azaan Time',
                            groupValue: selectedOption,
                            activeColor: Colors.brown,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value!;
                              });
                            },
                          ),
                          Text(
                            TKeys.azaanTime.translate(context),
                            style: TextStyle(
                              color: Colors.brown.shade700,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: 'All LEDs On',
                            groupValue: selectedOption,
                            activeColor: Colors.brown,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value!;
                              });
                            },
                          ),
                          Text(
                            TKeys.leds.translate(context),
                            style: TextStyle(
                              color: Colors.brown.shade700,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: 'Noise in Azaan',
                            groupValue: selectedOption,
                            activeColor: Colors.brown,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value!;
                              });
                            },
                          ),
                          Text(
                            TKeys.noise.translate(context),
                            style: TextStyle(
                              color: Colors.brown.shade700,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: 'Other',
                            groupValue: selectedOption,
                            activeColor: Colors.brown,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value!;
                              });
                            },
                          ),
                          Text(
                            TKeys.other.translate(context),
                            style: TextStyle(
                              color: Colors.brown.shade700,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // leave side note
                Text(
                  TKeys.note.translate(context),
                  style: TextStyle(
                      color: Colors.brown.shade700,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: controllerNote,
                  cursorColor: Colors.brown.shade700,
                  decoration: InputDecoration(
                    floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                        (Set<MaterialState> states) {
                      final Color color = states.contains(MaterialState.error)
                          ? Theme.of(context).colorScheme.error
                          : Colors.brown.shade900;
                      return TextStyle(color: color, letterSpacing: 1.3);
                    }),
                    labelStyle: MaterialStateTextStyle.resolveWith(
                        (Set<MaterialState> states) {
                      final Color color = states.contains(MaterialState.error)
                          ? Theme.of(context).colorScheme.error
                          : Colors.brown.shade800;
                      return TextStyle(color: color, letterSpacing: 1.3);
                    }),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(width: 1, color: Colors.brown),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(width: 1, color: Colors.brown),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      msg = value;
                    });
                  },
                ),
                // store data
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: width * .8,
                    child: ElevatedButton(
                      onPressed: () {
                        try {
                          if(selectedOption.isNotEmpty){
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.name)
                                .collection('feedback').doc('$setDay-$setMonth-$setYear-$formattedTime')
                                .set({
                              'problem': selectedOption,
                              'msg': msg,
                              'time of unit': formattedTime,
                              'date of unit': formattedDate,
                              'longitude of mobile':storedLongitude,
                              'latitude of mobile':storedLatitude,
                              'longitude of unit':unitLongitude,
                              'latitude of unit':unitLatitude,
                            }).then((value) => Navigator.pop(context,true));
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill input')),
                            );
                          }
                        } catch (error) {
                          if (kDebugMode) {
                            print(error);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.brown.shade400,
                          backgroundColor: Colors.brown,
                          disabledForegroundColor: Colors.brown.shade600,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: Text(
                        TKeys.submit.translate(context),
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
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
