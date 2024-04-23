// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Details/Register.dart';
import '../controller/Constant.dart';
import 'package:intl/intl.dart';
class Events {
  final String id;
  final String title;
  final String address;
  final String description;
  final String imagePath;
  final DateTime startDate;
  final DateTime endDate;

  Events({
    required this.id,
    required this.title,
    required this.address,
    required this.description,
    required this.imagePath,
    required this.startDate,
    required this.endDate,
  });

  factory Events.fromJson(Map<String, dynamic> json) {
    return Events(
      id: json['id'],
      title: json['title'],
      address: json['address'],
      description: json['description'],
      imagePath: json['imagePath'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}

class Accueil extends StatefulWidget {
  const Accueil({Key? key}) : super(key: key);

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  late Future<List<Events>> _events;

  final TextEditingController _eventSearch = TextEditingController();
 String url = Constant.apiUrl;
  @override
  void initState() {
    super.initState();
    _events = fetchEvents();
  }

  Future<List<Events>> fetchEvents() async {
    final response =
        await http.get(Uri.parse('$url/event'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Events> events = data.map((e) => Events.fromJson(e)).toList();
      return events;
    } else {
      throw Exception('Failed to load events');
    }
  }

  List<Events> filterEvents(List<Events> events, String query) {
    return events
        .where((event) => event.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.asset(
                    'assets/images/banner.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250,
                  ),
                  Positioned(
                    top: 25,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        height: 50,
                        child: TextFormField(
                          controller: _eventSearch,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.6),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFFEEBC54),
                            ),
                            hintText: 'Search For Event',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding:  EdgeInsets.all(16.0),
                child: Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF74b2da),
                  ),
                ),
              ),
              FutureBuilder<List<Events>>(
                future: _events,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Events> events = snapshot.data!;
                    if (_eventSearch.text.isNotEmpty) {
                      events = filterEvents(events, _eventSearch.text);
                    }
                    return SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          Events event = events[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EventDetailsPage(event: event)),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.all(10),
                              width: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                    child: Image.network(
                                      event.imagePath,
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          event.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          event.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventDetailsPage extends StatelessWidget {
  final Events event;
   EventDetailsPage({Key? key, required this.event}) : super(key: key);
 String url = Constant.apiUrl;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                event.imagePath,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Text(
              event.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Address: ${event.address}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            Text(DateFormat('yyyy-MM-dd').format(event.startDate),style:TextStyle(
              fontSize: 16,
              color:Colors.blue[700],
              fontWeight: FontWeight.bold,
            )),
            SizedBox(height: 10),
            Text(
              'Description: ${event.description}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
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
                backgroundColor: Colors.yellow[600],
              ),
              child:  Text('Register Now'),
            ),
            SizedBox(height: 20),
            Text(
              "Sessions of Event",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            FutureBuilder<List<dynamic>>(
              future: fetchEventSessions(event.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<dynamic> sessions = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return ExpansionTile(
                        
                        title:Text(session['name'] ?? 'Unnamed Session',style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(session['startDate'].split('T')[1]  +" // "+session["endDate"].split('T')[1]) ,
                        children:[
                          
                          ListTile(
                            leading:CircleAvatar(
                              backgroundColor:Color(0xFFFFB703),
                              child:Text(session['numPlace'].toString())),
                            title: Text(session['description'] ?? ''),
                          ),
                         
                        ]
                      
                        
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<dynamic>> fetchEventSessions(String eventId) async {
    final response = await http.get(Uri.parse('$url/Session/GetSessionByEventId/$eventId'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to load event sessions');
    }
  }
}


void main() {
  runApp(Accueil());
}
