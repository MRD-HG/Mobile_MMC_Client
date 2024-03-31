import 'dart:convert';
import 'package:client_mobile/Error/Error404.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Event extends StatefulWidget {
  const Event({super.key});

  @override
  State<Event> createState() => _EventState();
}

class _EventState extends State<Event> {
  List<dynamic> events = [];
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('https://smallorangerock30.conveyor.cloud/gateway/event'));
      if (response.statusCode == 200) {
        setState(() {
          events = json.decode(response.body);
        });
      } else {
        throw Exception("Failed to load events");
      }
    } catch (e) {
      Navigator.push(
          context, MaterialPageRoute(builder: ((context) => Error404())));
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
            itemCount: events.length,
            itemBuilder: (BuildContext context, int index) {
              final event = events[index];
              return ListTile(
                title: Text(event['title']),
                subtitle: Text(event['description']),
                leading: Image.network(event['imagePath'],width: 100,height: 100,),
              );
            }));
  }
}
