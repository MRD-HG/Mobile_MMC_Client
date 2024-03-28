import 'package:client_mobile/view/Accueil.dart';
import 'package:client_mobile/view/Event.dart';
import 'package:client_mobile/view/Program.dart';
import 'package:client_mobile/view/Session.dart';
import 'package:client_mobile/view/Speaker.dart';
import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';

class MontionTabBarPage extends StatelessWidget {
   MontionTabBarPage({super.key});
  final screens = [Accueil(),Sessions(),Speaker(),Program(),Event()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Accueil() ,
      bottomNavigationBar: MotionTabBar(
        initialSelectedTab: "Acceuil",
        labels: ["Accueil","Program","Events","Sessions","Speakers"],
        tabIconColor: Color(0xFF74b2da),
        tabSelectedColor: Color.fromARGB(255, 95, 166, 214),
        icons: [Icons.home_filled,Icons.calendar_view_month,Icons.event_note,Icons.access_time_filled,Icons.account_circle],
        // onTabItemSelected: ,
      )
    );
  }
}