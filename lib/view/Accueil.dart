// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(

        body: MainAccueil(),
      ),
      
    );
  }
}

class MainAccueil extends StatefulWidget {
  const MainAccueil({super.key});

  @override
  State<MainAccueil> createState() => _MainAccueilState();
}

class _MainAccueilState extends State<MainAccueil> {
  @override
  Widget build(BuildContext context) {
    return  Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                
                child:Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Color(0xFF74b2da),

                    borderRadius: BorderRadius.only(bottomLeft:Radius.circular(20) ,bottomRight: Radius.elliptical(20, 15)),
                    
                  ),
                  child:Column(
                      children: [
                        SizedBox(height:20),
                        TextFormField()
                      ]
                    )
                        )
                        
                ),
                
              
            ],
          )
        ],
      ),

    );
  }
}