import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Error404 extends StatelessWidget {
   Error404({super.key});
   var size, height, width;
  @override 
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height=size.height;
    width = size.width;

    return Scaffold(
      body: Center(
        child: Container(
          height: height * .7,
          width: width * .7,
          
          child: Image(image: AssetImage("assets/images/404ErrorPage.png")),
        ),
      ),
    );
  }
}