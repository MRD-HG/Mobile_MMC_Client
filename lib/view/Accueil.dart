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
    final response = await http.get(Uri.parse('https://smallorangerock30.conveyor.cloud/gateway/event'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Events> events = data.map((e) => Events.fromJson(e)).toList();
      return events;
    } else {
      throw Exception('Failed to load events');
    }
  }

  List<Events> filterEvents(List<Events> events, String query) {
    return events.where((event) => event.title.toLowerCase().contains(query.toLowerCase())).toList();
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
              Padding(
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
                        itemBuilder: (context, index) {
                          Events event = events[index];
                          return Container(
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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

void main() {
  runApp(Accueil());
}
