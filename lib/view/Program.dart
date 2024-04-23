import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';


import '../controller/Constant.dart';

class Program extends StatefulWidget {
  Program({super.key});

  @override
  State<Program> createState() => _ProgramState();
}

class _ProgramState extends State<Program> {
  List<dynamic> programs = [];
  String url = Constant.apiUrl;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('$url/program'));
      if (response.statusCode == 200) {
        setState(() {
          programs = json.decode(response.body);
        });
      } else {
        throw Exception("Failed to load Programs");
      }
    } catch (e) {
      // Handle error
      print(e);
    }
  }
  Widget build(BuildContext context) {
  if (programs.isEmpty) {
    return Center(
      child: CircularProgressIndicator(), 
    );
  } else {
    return Scaffold(
      body: ListView.builder(
        itemCount: programs.length, 
        itemBuilder: (BuildContext context, int index) {
          final program = programs[index];
          return ListTile(
            title: Container(
              color: Colors.yellow[600],
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width * 0.7,
                child: Center(
                  child:Text(program['title'],style:TextStyle(fontSize:20,color: Colors.white,fontWeight:FontWeight.bold)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
}