import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:programBody(),
    );
  }
  Widget programBody()=>Container(
    child: programs.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: programs.length,
              itemBuilder: (BuildContext context, int index) {
                final program = programs[index];
                return ListTile(
                  title: Container(
                    color: Colors.white,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                           ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX:10,
                              sigmaY:10,
                            ),
                            child:Image.asset('assets/images/1702198475838.jpg',
                            fit: BoxFit.fill,) ,
                            ),
                          Container(
                            color: Colors.black.withOpacity(0.4),
                          ),
                          Text(
                            program['title'],
                            style: TextStyle(fontSize: 30, color: Colors.white,fontWeight: FontWeight.bold),
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
