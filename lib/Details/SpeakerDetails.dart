import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../controller/Constant.dart';

class SpeakerDetailsPage extends StatefulWidget {
  final String speakerName;
  final String idspeaker;

  SpeakerDetailsPage({required this.speakerName, required this.idspeaker});

  @override
  State<SpeakerDetailsPage> createState() => _SpeakerDetailsPageState();
}

class _SpeakerDetailsPageState extends State<SpeakerDetailsPage> {
  String url = Constant.apiUrl;
  Map<String, dynamic> speakerDetails = {};
  bool isLoading = true;
  final double coverHeight = 280;
  final double profilHeight = 144;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('$url/speaker/${widget.idspeaker}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          speakerDetails = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to Load Speaker Details");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Speaker Details', style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                topBody(),
                bodyContent(),
              ],
            ),
    );
  }

  Widget socialMedia(IconData icon) => CircleAvatar(
        radius: 25,
        child: Material(
          shape: CircleBorder(),
          clipBehavior: Clip.hardEdge,
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            child: Center(
                child: Icon(
              icon,
              size: 28,
              color: Color(0xFFEEBC54),
            )),
          ),
        ),
      );

  Widget bodyContent() => Column(
        children: [
          SizedBox(height: 8),
          Text(
            speakerDetails['firstname'] + ' ' + speakerDetails['lastname'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            speakerDetails['bio'],
            style: TextStyle(fontSize: 20, color: Colors.black38),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              socialMedia(FontAwesomeIcons.xTwitter),
              SizedBox(width: 5),
              socialMedia(FontAwesomeIcons.facebook),
              SizedBox(width: 5),
              socialMedia(FontAwesomeIcons.instagram),
              SizedBox(width: 5),
              socialMedia(FontAwesomeIcons.linkedinIn),
              SizedBox(width: 5),
              socialMedia(FontAwesomeIcons.github),
            ],
          ),
          SizedBox(height: 8),
          bodyAbout(),
        ],
      );

  Widget bodyAbout() => Container(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 14),
            Text(
              speakerDetails['description'],
              style: TextStyle(fontSize: 18, height: 1.4),
            ),
            SizedBox(height: 18),
          ],
        ),
      );

  Widget buildImage() => Container(
        color: Colors.white,
        child: Image.asset('assets/images/1702198475838.jpg'),
        width: double.infinity,
        height: coverHeight,
      );

  Widget profilImage() => CircleAvatar(
        radius: profilHeight / 2,
        backgroundColor: Color.fromARGB(255, 217, 245, 198),
        backgroundImage: AssetImage('assets/images/said_wahid.png'),
      );

  Widget topBody() {
    final top = coverHeight - profilHeight / 2;
    final bottom = profilHeight / 2;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottom),
          child: buildImage(),
        ),
        Positioned(
          top: top,
          child: profilImage(),
        )
      ],
    );
  }
}
