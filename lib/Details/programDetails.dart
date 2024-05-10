import 'dart:convert';
import 'package:flutter/material.dart';
// ignore_for_file: unused_import


import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../Details/Register.dart';
import '../controller/Constant.dart';

class EventProgram extends StatefulWidget {
  final String programId;

  const EventProgram({Key? key, required this.programId}) : super(key: key);

  @override
  State<EventProgram> createState() => _EventProgramState();
}

class _EventProgramState extends State<EventProgram> with TickerProviderStateMixin {
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
      final response = await http.get(Uri.parse('$url/Event/GetEventsByProgramId/${widget.programId}'));
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
      // _showErrorDialog();
    }
  }
  // List<Event> filterEvents(List<Event> events , String query){
  //   return events
  //       .where((event) => event.title.toLowerCase().contains(query.toLowerCase())).toList();
  // }

  // void _showErrorDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text("Error"),
  //       content: Text("Failed to load data. Please check your connection and try again."),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop(); // Close the dialog
  //             fetchData(); // Retry fetching data
  //           },
  //           child: Text("Retry"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  List<dynamic> searchEvents() {
    String query = _searchController.text.toLowerCase();
    return events.where((event) {
      return event['title'].toString().toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text('Events', style: TextStyle(color: Colors.blue[600])),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search events by name',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: searchEvents().length,
                      itemBuilder: (context, index) => eventCard(searchEvents()[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

 Widget eventCard(dynamic event) => Card(
  clipBehavior: Clip.antiAlias,
  child: Column(
    children: [
      Image.network(
        event['imagePath'],
        fit: BoxFit.cover,
        height: 200,
      ),
      ListTile(
        title: Text(event['title'], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${event['startDate']} - ${event['endDate']}"),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[600],

          ) ,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterForm(idEvent: event['id'].toString())),
            );
          },
          child: Text('Register'),
        ),
      ),
    ],
  ),
);
}