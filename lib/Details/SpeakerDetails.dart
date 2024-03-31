import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SpeakerDetailsPage extends StatefulWidget {
  final String speakerName;
  final String idspeaker;

  SpeakerDetailsPage({required this.speakerName, required this.idspeaker});

  @override
  State<SpeakerDetailsPage> createState() => _SpeakerDetailsPageState();
}

class _SpeakerDetailsPageState extends State<SpeakerDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  Map<String, dynamic> speakerDetails = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    fetchData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://smallorangerock30.conveyor.cloud/gateway/speaker/${widget.idspeaker}'),
     );
      if (response.statusCode == 200) {
        setState(() {
          speakerDetails = json.decode(response.body);
          _controller.forward();
        });
      } else {
        throw Exception("Failed to Load Speaker Details");
      }
    } catch (e) {}
  }

  @override
    Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Speaker Details'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow[600], // primary-yellow: #eebc54
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4.0),
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: AssetImage(
                      'assets/images/hassan_fadili.jpg',
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.speakerName,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          speakerDetails['bio'] ?? '',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Company: ${speakerDetails['company'] ?? ''}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Email: ${speakerDetails['email'] ?? ''}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Description: ${speakerDetails['description'] ?? ''}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Social Media:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        if (speakerDetails['speakerSocialMedia'] != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (speakerDetails['speakerSocialMedia']['linkedin'] != null)
                                _buildSocialMediaRow(
                                  icon: FontAwesomeIcons.linkedin,
                                  text: 'LinkedIn',
                                  link: speakerDetails['speakerSocialMedia']['linkedin'],
                                ),
                              if (speakerDetails['speakerSocialMedia']['instagram'] != null)
                                _buildSocialMediaRow(
                                  icon: FontAwesomeIcons.instagram,
                                  text: 'Instagram',
                                  link: speakerDetails['speakerSocialMedia']['instagram'],
                                ),
                              if (speakerDetails['speakerSocialMedia']['facebook'] != null)
                                _buildSocialMediaRow(
                                  icon: FontAwesomeIcons.facebook,
                                  text: 'Facebook',
                                  link: speakerDetails['speakerSocialMedia']['facebook'],
                                ),
                              if (speakerDetails['speakerSocialMedia']['x'] != null)
                                _buildSocialMediaRow(
                                  icon: FontAwesomeIcons.twitter,
                                  text: 'Twitter',
                                  link: speakerDetails['speakerSocialMedia']['x'],
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

  Widget _buildSocialMediaRow({
    required IconData icon,
    required String text,
    required String link,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 8.0),
          TextButton(
            onPressed: () {
              // Handle social media link click
            },
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

