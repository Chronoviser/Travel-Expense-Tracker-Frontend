import 'package:frontend/models/activity.dart';

class Trip {
  String id;
  String tripName;
  String from;
  String to;
  List<String> travellers = [];
  List<Activity> activities = [];

  Trip(this.tripName, this.from, this.to, this.travellers);

  Trip.withActivity(this.id, this.tripName, this.from, this.to, this.travellers,
      this.activities);

  Trip.fromJSON(Map<String, dynamic> json) {
    id = json['_id'];
    tripName = json['tripName'];
    from = json['from'];
    to = json['to'];
    json['travellers'].forEach((s) => travellers.add(s));
    json['activities'].forEach((a) => activities.add(Activity.fromJSON(a)));
  }

  // ignore: non_constant_identifier_names
  TripToJSON() {
    List<dynamic> _activities = [];
    this.activities.forEach((e) => _activities.add(e.ActivityToJSON()));
    return {
      'tripName': this.tripName,
      'from': this.from,
      'to': this.to,
      'travellers': this.travellers,
      'activities': _activities
    };
  }

  // ignore: non_constant_identifier_names
  TripToJsonWithId() {
    List<dynamic> _activities = [];
    this.activities.forEach((e) => _activities.add(e.ActivityToJSON()));
    return {
      '_id': this.id,
      'tripName': this.tripName,
      'from': this.from,
      'to': this.to,
      'travellers': this.travellers,
      'activities': _activities
    };
  }
}