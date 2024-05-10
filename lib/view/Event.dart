import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Details/Register.dart';
import '../controller/Constant.dart';

class Event extends StatefulWidget {
  const Event({Key? key}) : super(key: key);

  @override
  State<Event> createState() => _EventState();
}

class _EventState extends State<Event> with TickerProviderStateMixin {
  List<dynamic> events = [];
  bool isLoading = true;
  String url = Constant.apiUrl;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('$url/event'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        setState(() {
          events = json.decode(response.body);
         
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load events");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text(
              "Failed to load data. Please check your connection and try again."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close the dialog
                fetchData(); // retry fetching data
              },
              child: Text("Retry"),
            ),
          ],
        ),
      );
    }
  }

  List<dynamic> getEvents(bool isUpcoming) {
    return events.where((event) {
      final eventDate = DateTime.parse(event['startDate']);
      return isUpcoming
          ? eventDate.isAfter(DateTime.now())
          : eventDate.isBefore(DateTime.now());
    }).where((event) {
      return event['title']
          .toString()
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: Text('Events', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search events by name',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.search),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    _buildEventSection(getEvents(true), 'Upcoming Events'),
                    _buildEventSection(getEvents(false), 'Passed Events'),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventSection(List<dynamic> eventList, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            title,
            style: TextStyle(
              color: Color(0xFFEEBC54),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: eventList.length,
          itemBuilder: (context, index) {
            final AnimationController controller = AnimationController(
              duration: const Duration(milliseconds: 500),
              vsync: this,
            );
            final Animation<double> opacityAnimation =
                Tween<double>(begin: 0.0, end: 1.0).animate(controller);
            controller.forward();

            return FadeTransition(
              opacity: opacityAnimation,
              child: cardEvent(eventList[index]),
            );
          },
        ),
      ],
    );
  }

  Widget cardEvent(dynamic event) => Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
           FittedBox(
            child : Image.network(
              event['imagePath'].startsWith('http')
                  ? event['imagePath']
                  : 'assets/images/blue.jpg',
              fit: BoxFit.fill,
              height: 170.0,
            ),
           ),
            Positioned(
              bottom: 16.0,
              left: 16.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'],
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "${event['startDate'].split('T')[1] } ${event['startDate'].split('T')[0] }",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          
            Positioned(
              bottom: 10.0,
              right: 10.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[600],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterForm(idEvent: event['id'].toString()),
                    ),
                  );
                },
                child : const Text(
                  "Register",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
}