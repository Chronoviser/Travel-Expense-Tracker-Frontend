import 'package:flutter/material.dart';
import 'package:frontend/my-trips.dart';


void main() {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: Colors.black, accentColor: Colors.black),
        home: Home());
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String password;
  final PASS_CODE = "UDAI";

  void checkPassword() {
    if(password == PASS_CODE) {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (context, _, __) =>
          MyTrips()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Travel Expense Tracker App"),
        ),
        body: Container(
          child: Column(children: [
            TextField(
              onChanged: (e) {
                password = e;
              },
            ),
            RaisedButton(
              child: Text("Go"),
              onPressed: checkPassword,
            )
          ]),
        ));
  }
}
