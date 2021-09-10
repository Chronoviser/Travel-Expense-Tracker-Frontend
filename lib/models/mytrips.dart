import 'package:frontend/models/trip.dart';

class MyTrips {
  static List<Trip> trips = new List();

  MyTrips.fromJSON(List<dynamic> json) {
    trips.clear();
    json.forEach((v) => trips.add(Trip.fromJSON(v)));
  }
}
