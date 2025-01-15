// ignore_for_file: prefer_const_constructors, unused_import


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../Details/Register.dart';
import '../Details/SpeakerDetails.dart';
import '../Details/SponsorCard.dart';
import '../controller/Constant.dart';

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
  final String url = Constant.apiUrl;

  @override
  void initState() {
    super.initState();
    _events = fetchEvents();
  }

  Future<List<Events>> fetchEvents() async {
    final response = await http.get(Uri.parse('$url/event'));
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
        appBar:AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(
            
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              _buildUpcomingEventsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Stack(
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
    );
  }

  Widget _buildUpcomingEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
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
              return _buildEventList(events);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }

  Widget _buildEventList(List<Events> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
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
                      builder: (context) => EventDetailsPage(event: event),
                    ),
                  );
                },
                child: _buildEventCard(event),
              );
            },
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Sponsors',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF74b2da),
            ),
          ),
        ),
        SizedBox(height: 10),
        SponsorFooter(),
      ],
    );
  }

  Widget _buildEventCard(Events event) {
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
  }

  Widget _buildSponsors() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildSponsorItem('Sponsor 1', 'assets/images/sponsor1.png'),
          _buildSponsorItem('Sponsor 2', 'assets/images/sponsor2.png'),
          _buildSponsorItem('Sponsor 3', 'assets/images/sponsor3.png'),
          
        ],
      ),
    );
  }

  Widget _buildSponsorItem(String title, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(imagePath),
          ),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class EventDetailsPage extends StatelessWidget {
  final Events event;
  final String url = Constant.apiUrl;

  EventDetailsPage({Key? key, required this.event}) : super(key: key);

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
            _buildEventImage(),
            SizedBox(height: 20),
            _buildEventTitle(),
            SizedBox(height: 10),
            _buildEventAddress(),
            _buildEventStartDate(),
            SizedBox(height: 10),
            _buildEventDescription(),
            SizedBox(height: 20),
            _buildRegisterButton(context),
            SizedBox(height: 20),
            _buildSessionsTitle(),
            _buildEventSessions(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        event.imagePath,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildEventTitle() {
    return Text(
      event.title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEventAddress() {
    return Text(
      'Address: ${event.address}',
      style: TextStyle(
        fontSize: 18,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildEventStartDate() {
    return Text(
      DateFormat('yyyy-MM-dd').format(event.startDate),
      style: TextStyle(
        fontSize: 16,
        color: Colors.blue[700],
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEventDescription() {
    return Text(
      'Description: ${event.description}',
      style: TextStyle(
        fontSize: 18,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterForm(idEvent: event.id,),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow[600],
      ),
      child: Text('Register Now'),
    );
  }

  Widget _buildSessionsTitle() {
    return Text(
      "Sessions of Event",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEventSessions() {
    return FutureBuilder<List<dynamic>>(
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
              return _buildSessionTile(session);
            },
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }

  Widget _buildSessionTile(dynamic session) {
    return ExpansionTile(
      title: Text(session['name'] ?? 'Unnamed Session', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(session['startDate'].split('T')[1] + " // " + session["endDate"].split('T')[1]),
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(0xFFFFB703),
            child: Text(session['numPlace'].toString()),
          ),
          title: Text(session['description'] ?? ''),
        ),
      ],
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
