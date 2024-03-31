import 'package:client_mobile/view/Accueil.dart';
import 'package:client_mobile/view/Event.dart';
import 'package:client_mobile/view/Program.dart';
import 'package:client_mobile/view/Session.dart';
import 'package:client_mobile/view/Speaker.dart';
import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:get/get.dart';
import 'package:client_mobile/controller/bottom_navigation_controller.dart';
//https://goodbrushedwave50.conveyor.cloud/gateway/event
class MontionTabBarPage extends StatelessWidget {
   MontionTabBarPage({super.key});
   BottomNavigationController bottomNavigationController=Get.put(BottomNavigationController());
  final screens = [Accueil(),Program(),Event(),Speaker()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack (
        index: bottomNavigationController.selectedIndex.value,
        children: screens,

      ) ),
      bottomNavigationBar: MotionTabBar(
        initialSelectedTab: "Accueil",
        labels: ["Accueil","Program","Events","Speakers"],
        tabIconColor: Color(0xFF74b2da),
        tabSelectedColor: Color.fromARGB(255, 95, 166, 214),
        tabSize: 30,
        icons: [Icons.home_filled,Icons.calendar_view_month,Icons.event_note,Icons.account_circle],
        textStyle: TextStyle(color: Color.fromARGB(255, 84, 157, 206),fontSize: 14),
        onTabItemSelected:(index){
          bottomNavigationController.changeIndex(index);
        } ,
      )
    );
  }
}