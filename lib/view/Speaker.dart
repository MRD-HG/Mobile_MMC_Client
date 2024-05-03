// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:client_mobile/Error/Error404.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:client_mobile/Details/SpeakerDetails.dart';
import '../controller/Constant.dart';
class Speaker extends StatefulWidget {
  const Speaker({super.key});

  @override
  State<Speaker> createState() => _SpeakerState();
}

class _SpeakerState extends State<Speaker> {
  List<dynamic> speakers = [];
  String url = Constant.apiUrl;
  
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('$url/speaker'));
      if (response.statusCode == 200) {
        setState(() {
          speakers = json.decode(response.body);
        });
      } else {
        throw Exception("Failed to Load Speakers");
      }
    } catch (e) {
      // Navigator.push(
      //   context, MaterialPageRoute(builder: ((context) => Error404())));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speakers'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left:10,right:10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.8,
          ),
          
          itemCount: speakers.length,
          itemBuilder: (BuildContext context, int index) {
            final speaker = speakers[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) => SpeakerDetailsPage(
                      idspeaker: '${speaker['id']}',
                      speakerName: '${speaker['firstname']} ${speaker['lastname']}',
                    ),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      var begin = Offset(1.0, 0.0);
                      var end = Offset.zero;
                      var curve = Curves.ease;
        
                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Card(
                elevation: 10,
        
        
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120.0, 
                        height: 120.0,
                        decoration:const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/images/said_wahid.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // SizedBox(height: 16.0),
                      Text(
                        '${speaker['firstname']} ${speaker['lastname']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                  
                      // SizedBox(height: 8.0),
                      Text(
                        speaker['bio'],
                        textAlign: TextAlign.center,
                        // maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
