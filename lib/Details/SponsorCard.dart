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

  Future<List<Sponsor>> fetchSponsors() async {
    final response = await http.get(Uri.parse('${Constant.apiUrl}/sponsor'));

    if (response.statusCode == 200) {
      return List<Sponsor>.from(json.decode(response.body).map((json) => Sponsor.fromJson(json)));
    } else {
      throw Exception('Failed to load sponsors');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Sponsor>>(
      future: _futureSponsors,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return SizedBox(
            height: 120, // Adjust height according to your UI needs
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return _buildSponsorItem(context, snapshot.data![index]);
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildSponsorItem(BuildContext context, Sponsor sponsor) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            padding: EdgeInsets.all(20),
            child: Text(sponsor.description),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          radius: 30, // Adjust size as needed
          backgroundImage: NetworkImage(sponsor.logo),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}

