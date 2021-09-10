import 'package:flutter/material.dart';
import 'package:frontend/api-handler/trip-handler.dart';
import 'package:frontend/models/trip.dart';
import 'package:frontend/trip-detail.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class MyTrips extends StatefulWidget {
  @override
  _MyTripsState createState() => _MyTripsState();
}

class _MyTripsState extends State<MyTrips> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool fetchingData = false;
  TripHandler tripHandler = new TripHandler();
  List<Trip> trips = [];

  Future<List<String>> createTripDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          TextEditingController tripController = TextEditingController();
          TextEditingController fromController = TextEditingController();
          TextEditingController toController = TextEditingController();

          List<TextEditingController> travelControllers = [
            new TextEditingController()
          ];

          int travellers = 1;

          Widget customTextField(
              {TextEditingController controller, String hintText}) {
            return TextFormField(
              controller: controller,
              validator: (value) {
                return value.isNotEmpty ? null : "Invalid Field";
              },
              decoration: InputDecoration(hintText: hintText),
            );
          }

          // ignore: non_constant_identifier_names
          Widget DatePicker({TextEditingController controller, String label}) {
            controller.text = '$label Date';
            final format = DateFormat("yyyy-MM-dd");
            return DateTimeField(
              controller: controller,
              format: format,
              onShowPicker: (context, _) {
                return showDatePicker(
                    context: context,
                    firstDate: DateTime(2021),
                    initialDate: DateTime.now(),
                    lastDate: DateTime(2100));
              },
              onChanged: (val) {
                controller.text =
                    DateFormat('yyyy-MM-dd').format(val).toString();
              },
            );
          }

          List<Widget> wids = [
            customTextField(controller: tripController, hintText: 'Trip Name'),
            DatePicker(controller: fromController, label: 'From'),
            DatePicker(controller: toController, label: 'To'),
            customTextField(
                controller: travelControllers[0], hintText: 'Traveller Name'),
          ];

          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: wids,
                    ),
                  )),
              actions: <Widget>[
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      List<String> tripData = [];
                      tripData.add(tripController.text.toString().trim());
                      tripData.add(fromController.text.toString().trim());
                      tripData.add(toController.text.toString().trim());
                      for (TextEditingController _controller
                          in travelControllers) {
                        tripData.add(_controller.text.toString().trim());
                      }
                      Navigator.of(context).pop(tripData);
                    }
                  },
                ),
                TextButton(
                  child: Text('Add Traveller'),
                  onPressed: () {
                    setState(() {
                      travelControllers.add(new TextEditingController());
                      wids.add(customTextField(
                          controller: travelControllers[travellers++],
                          hintText: 'Traveller$travellers\'s Name'));
                    });
                  },
                )
              ],
            );
          });
        });
  }

  // ignore: non_constant_identifier_names
  Widget TravelCard({Trip tripData}) {
    return GestureDetector(
      onTap: () async {
        bool response = await Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (context, _, __) => TripDetail(tripData: tripData)));
        if (response) fetchMyTrips();
      },
      child: Card(
        color: Color.fromRGBO(250, 235, 215, 1),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  tripData.tripName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                GestureDetector(
                    onTap: () {
                      deleteTrip(tripData.id);
                    },
                    child: Icon(Icons.delete, color: Colors.black54))
              ]),
              SizedBox(height: 10),
              Text(
                '${tripData.travellers.length} Travellers',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tripData.from, style: TextStyle(fontSize: 16)),
                  Text('-', style: TextStyle(fontSize: 16)),
                  Text(tripData.to, style: TextStyle(fontSize: 16))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("My Trips"),
      ),
      body: fetchingData
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: trips.length,
              itemBuilder: (BuildContext context, int index) {
                return TravelCard(tripData: trips[trips.length - index - 1]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          createTripDialog(context).then((value) {
            if (value != null && value.length > 0) {
              List<String> _travellers = [];
              for (int i = 3; i < value.length; i++) _travellers.add(value[i]);
              Trip newTrip =
                  new Trip(value[0], value[1], value[2], _travellers);
              createTrip(newTrip);
            }
          });
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchMyTrips();
  }

  showNetworkError() {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Network Error!')));
  }

  fetchMyTrips() async {
    setState(() {
      fetchingData = true;
    });
    trips = await tripHandler.getMyTrips();
    setState(() {
      fetchingData = false;
    });
  }

  createTrip(newTrip) async {
    var response = await tripHandler.createTrip(newTrip);
    if (response)
      setState(() {
        fetchMyTrips();
      });
    else
      showNetworkError();
  }

  deleteTrip(id) async {
    var response = await tripHandler.deleteTrip(id);
    if (response)
      setState(() {
        fetchMyTrips();
      });
    else
      showNetworkError();
  }
}
