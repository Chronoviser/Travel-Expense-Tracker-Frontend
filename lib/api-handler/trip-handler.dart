import 'package:dio/dio.dart';
import 'package:frontend/models/mytrips.dart';
import 'package:frontend/models/trip.dart';

class TripHandler {
  Dio dio = new Dio();
  final baseURL =
      "https://travel-expense-tracker-backend.herokuapp.com/mytrips";

  Future<dynamic> getMyTrips() async {
    var response = await dio.get(baseURL);
    MyTrips.fromJSON(response.data);
    return MyTrips.trips;
  }

  Future<bool> createTrip(Trip newTrip) async {
    try {
      await dio.post(baseURL, data: newTrip.TripToJSON());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteTrip(String id) async {
    try {
      dio.delete(baseURL + '/' + id);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateTrip(Trip updatedTrip) async {
    try {
      await dio.patch(baseURL + '/' + updatedTrip.id,
          data: updatedTrip.TripToJsonWithId());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
