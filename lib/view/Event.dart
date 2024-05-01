// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';
//import 'package:client_mobile/Error/Error404.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Details/Register.dart';
import '../controller/Constant.dart';

class Event extends StatefulWidget {
  const Event({Key? key});

  @override
  State<Event> createState() => _EventState();
}

class _EventState extends State<Event> {
  List<dynamic> events = [];
  String url = Constant.apiUrl;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('$url/event'));
      if (response.statusCode == 200) {
        setState(() {
          events = json.decode(response.body);
        });
      } else {
        throw Exception("Failed to load events");
      }
    } catch (e) {
      // Navigator.push(
      //   context, MaterialPageRoute(builder: ((context) => Error404())));
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
      ),
      body: event(),
    );
  }

  Widget event() {
    return SingleChildScrollView(
      child: Stack(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
                decoration: InputDecoration(
                    hintText: 'Event Name',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(1),
                      child: Icon(Icons.search),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)))),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  Text(
                    "Upcoming",
                    style: TextStyle(
                        color: Color(0xFFEEBC54),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 5),
                  Text("Events",
                      style: TextStyle(
                          color: Color(0xFF74b2da),
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ]),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Column(children: [
                cardEvent(),
                SizedBox(height:10),
                cardEvent(),
                SizedBox(height:10),
                cardEvent(),
                SizedBox(height:10),
                cardEvent(),
              
              ]),
            ),
          ),
        ],
      )
    ])
    );
  }

  Widget cardEvent() => Card(
        clipBehavior: Clip.antiAlias, 
        child: Stack(
          children: [
            Image.asset(
              "assets/images/tanger.jpg",
              
              fit: BoxFit.cover,
              height: 170.0, 
            ),
            Positioned(
              bottom: 16.0,
              left: 16.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Event Title",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Date & Time",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10.0,
              right: 10.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[600]),
                onPressed: () {},
                child: Text("Book Now",style:TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );



  Widget eventPage() => ListView.builder(
        itemCount: events.length,
        itemBuilder: (BuildContext context, int index) {
          final event = events[index];
          return Column(
            children: [
              SizedBox(height: 10),
              Container(padding: EdgeInsets.all(10), child: TextFormField()),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 155, 191, 215),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(event['imagePath']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        event['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event['description'],
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterForm(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB703),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          child: Text(
                            'Register',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
}
