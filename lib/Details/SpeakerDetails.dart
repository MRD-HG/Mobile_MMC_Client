// pages/speaker_details_page.dart
import 'package:flutter/material.dart';
import '../models/speaker.dart';
import '../data/speaker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SpeakerDetailsPage extends StatelessWidget {
  final String speakerId;

  SpeakerDetailsPage({required this.speakerId, required String speakerName, required String idspeaker});

  @override
  Widget build(BuildContext context) {
    // Find the speaker by ID
    final Speaker speaker =
    speakersData.firstWhere((speaker) => speaker.id == speakerId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Speaker Details', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _topBody(speaker),
          _bodyContent(speaker),
        ],
      ),
    );
  }

  Widget _topBody(Speaker speaker) {
    final double coverHeight = 280;
    final double profileHeight = 144;
    final top = coverHeight - profileHeight / 2;
    final bottom = profileHeight / 2;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottom),
          child: Container(
            color: Colors.white,
            width: double.infinity,
            height: coverHeight,
            child: Image.asset(
              'assets/images/cover.jpg', // Placeholder cover image
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: top,
          child: CircleAvatar(
            radius: profileHeight / 2,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(speaker.image),
          ),
        ),
      ],
    );
  }

  Widget _bodyContent(Speaker speaker) => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        SizedBox(height: 80),
        Text(
          speaker.name,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          speaker.role,
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
        SizedBox(height: 16),
        _socialMedia(speaker),
      ],
    ),
  );

  Widget _socialMedia(Speaker speaker) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (speaker.social.facebook != null)
        IconButton(
          icon: FaIcon(FontAwesomeIcons.facebook),
          onPressed: () {
            _launchURL(speaker.social.facebook!);
          },
          color: Colors.blue,
        ),
      if (speaker.social.linkedin != null)
        IconButton(
          icon: FaIcon(FontAwesomeIcons.linkedin),
          onPressed: () {
            _launchURL(speaker.social.linkedin!);
          },
          color: Colors.blue[700],
        ),
      if (speaker.social.instagram != null)
        IconButton(
          icon: FaIcon(FontAwesomeIcons.instagram),
          onPressed: () {
            _launchURL(speaker.social.instagram!);
          },
          color: Colors.pink,
        ),
    ],
  );

  void _launchURL(String url) async {
    // Use url_launcher package to open URLs
    // Add url_launcher to pubspec.yaml dependencies
    // and import it: import 'package:url_launcher/url_launcher.dart';
    // Example:
    /*
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
    */
  }
}
