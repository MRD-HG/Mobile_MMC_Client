
import 'package:client_mobile/view/montion_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'view/Accueil.dart';

void main() {
  runApp(const LodingPage());
}

class LodingPage extends StatelessWidget {
  const LodingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
        home: Scaffold(
      body: Loding(),
    ));
  }
}

class Loding extends StatefulWidget {
  const Loding({super.key});

  @override
  State<Loding> createState() => _LodingState();
}

class _LodingState extends State<Loding> {
  @override
  void initState() {
    super.initState();
    navigateToMain();
  }

  Route route = MaterialPageRoute(builder: ((context) =>  MontionTabBarPage()));
  void navigateToMain() {
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(context, route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
          mainAxisAlignment: MainAxisAlignment.center,

              children: [
                const Padding(
                    padding: EdgeInsets.all(1),
                    child: Center(
                      child: Image(
                        image: AssetImage('assets/images/1702198475838.jpg'),
                        width: 150,
                        height: 150,
                      ),
                    )),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: SpinKitWave(
                    color: Colors.orange[600],
                    size: 30,
                  ),
                )
              ],
            ),
          ],
        )),
      ),
    );
  }
}
