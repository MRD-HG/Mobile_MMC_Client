// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

class Eventspeaker {
  final String? id;
  final String imagePath;

  Eventspeaker({
    required this.id,
    required this.imagePath,
  });

  factory Eventspeaker.fromJson(Map<String, dynamic> json) {
    return Eventspeaker(id: json['id'] as String? ?? "", imagePath: json['imagePath']);
  }
}

class Accueil extends StatefulWidget {
  const Accueil({Key? key}) : super(key: key);

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  late Future<List<Events>> _events;

  TextEditingController _eventSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    _events = fetchEvents();
  }

  Future<List<Events>> fetchEvents() async {
    final response =
        await http.get(Uri.parse('http://10.5.230.9:45460/gateway/event'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Events> events =
          data.map((e) => Events.fromJson(e)).toList();
      return events;
    } else {
      throw Exception('Failed to load events');
    }
  }

  List<Events> filterEvents(List<Events> events, String query) {
    return events
        .where((event) =>
            event.title.toLowerCase().contains(query.toLowerCase()))
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
                padding: const EdgeInsets.all(16.0),
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
                        itemBuilder: (contxt, index) {
                          Events event = events[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EventDetailsPage(event: event)),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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

class EventDetailsPage extends StatefulWidget {
  final Events event;

  const EventDetailsPage({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late Future<List<Eventspeaker>> _eventSpeakers;

  @override
  void initState() {
    super.initState();
  
    if (widget.event.id != null) {
    
    _eventSpeakers = fetchEventSpeakers(widget.event.id!);
  } else {
    
  
  }
   
  }

  Future<List<Eventspeaker>> fetchEventSpeakers(String? eventId) async {
   
    final response = await http.get(
        Uri.parse('http://10.5.230.9:45460/gateway/EventSpeakers/AllspeakersByEvent/$eventId'));

      List<dynamic> data = jsonDecode(response.body);
      print('here is the data==>${data}');
      List<Eventspeaker> speakers =
          data.map((e) => Eventspeaker.fromJson(e)).toList();
      return speakers;
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: FutureBuilder<List<Eventspeaker>>(
          future: _eventSpeakers,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Eventspeaker> speakers = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      widget.event.imagePath,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.event.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Address: ${widget.event.address}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Description: ${widget.event.description}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Speakers:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: speakers.length,
                    itemBuilder: (context, index) {
                      Eventspeaker speaker = speakers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(speaker.imagePath),
                        ),
                        title: Text('Speaker ${index + 1}'),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Handle registration
                    },
                    child: Text('Register Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[600],
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
                 print("${snapshot.error }");
                 print("${snapshot.hashCode}");
              return Center(
                child: Text("${snapshot.error}"),
             
                
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(Accueil());
}
