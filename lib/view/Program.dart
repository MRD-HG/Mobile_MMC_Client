import 'dart:convert';
import 'package:client_mobile/Error/Error404.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class Program extends StatefulWidget {
   Program({super.key});

  @override
  State<Program> createState() => _ProgramState();
}

class _ProgramState extends State<Program> {
  List <dynamic> programs=[];
  @override
  void initState(){
    super.initState();
    fetchData();
  }
  Future<void> fetchData() async{
    try{
      final response = await http.get(Uri.parse('http://10.5.230.9:45460/gateway/program'));
      if(response.statusCode==200){
        setState(() {
          programs=json.decode(response.body);
        });
      }
        else{
          throw Exception("Failed to load Programs");
        }
      }
    
    catch(e){
      Navigator.push(context, MaterialPageRoute(builder: ((context)=>Error404())));
    }
  }

  Widget build(BuildContext context) {
    return   Scaffold(
      body:ListView.builder(
        itemBuilder:(BuildContext context,int index){
          final program = programs[index];
          return ListTile(
            title: Text(program['title']),
          );
        }
     ) );
  }
}