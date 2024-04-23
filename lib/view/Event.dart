import 'dart:convert';
import 'package:client_mobile/Error/Error404.dart';
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
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (BuildContext context, int index) {
          final event = events[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color.fromARGB(255, 155, 191, 215), 
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
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
                  SizedBox(height: 16),
                  Text(
                    event['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    event['description'],
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(height: 16),
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
                      backgroundColor: Color(0xFFFFB703), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      child: Text(
                        'Register',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
