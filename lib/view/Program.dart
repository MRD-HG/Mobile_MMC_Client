import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_blurhash/flutter_blurhash.dart';
import '../controller/Constant.dart';

class Program extends StatefulWidget {
  Program( {super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: programs.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: programs.length,
              itemBuilder: (BuildContext context, int index) {
                final program = programs[index];
                return ListTile(
                  title: Container(
                    color: Colors.yellow[600],
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 200, // Adjust the height as needed
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          BlurHash(
                            hash: 'assets/images/1702198475838.png',
                            imageFit: BoxFit.cover,
                          ),
                          Text(
                            program['title'],
                            style:
                                TextStyle(fontSize: 30, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}