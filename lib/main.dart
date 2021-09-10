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
  // ignore: non_constant_identifier_names
  final PASS_CODE = "UDAI";

  void checkPassword(password) {
    if (password == PASS_CODE) {
      Navigator.of(context).pushReplacement(
          PageRouteBuilder(pageBuilder: (context, _, __) => MyTrips()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Travel Expense Tracker App"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/background.jpg"), fit: BoxFit.cover),
        ),
        child: Center(
          child: Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(horizontal: 60),
            child: TextField(
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                  hintText: "Enter Password Here", border: InputBorder.none),
              onChanged: checkPassword,
            ),
          ),
        ),
      ),
    );
  }
}
