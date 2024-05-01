import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../controller/Constant.dart';

class Sponsor {
  final String id;
  final String name;
  final String description;
  final String logo;

  Sponsor({required this.id, required this.name, required this.description, required this.logo});

  factory Sponsor.fromJson(Map<String, dynamic> json) {
    return Sponsor(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      logo: json['logo'],
    );
  }
}

class SponsorFooter extends StatefulWidget {
  @override
  _SponsorFooterState createState() => _SponsorFooterState();
}

class _SponsorFooterState extends State<SponsorFooter> {
  late Future<List<Sponsor>> _futureSponsors;

  @override
  void initState() {
    super.initState();
    _futureSponsors = fetchSponsors();
  }
  String uri = Constant.apiUrl; 

  Future<List<Sponsor>> fetchSponsors() async {
    final response = await http.get(Uri.parse('$uri/sponsor'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Sponsor.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sponsors');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.all(16.0),
      child: FutureBuilder<List<Sponsor>>(
        future: _futureSponsors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Column(
              children: [
                Text(
                  'Our Sponsors',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                SizedBox(height: 16.0),
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  children: snapshot.data!.map((sponsor) {
                    return SponsorCard(sponsor: sponsor);
                  }).toList(),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class SponsorCard extends StatelessWidget {
  final Sponsor sponsor;

  SponsorCard({required this.sponsor});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              sponsor.logo,
              width: 100,
              height: 100,
            ),
            SizedBox(height: 8.0),
            Text(
              sponsor.name,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.0),
            Text(
              sponsor.description,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
