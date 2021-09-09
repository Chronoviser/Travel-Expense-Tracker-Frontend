import 'package:flutter/material.dart';
import 'package:frontend/trip.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class MyTrips extends StatefulWidget {
  @override
  _MyTripsState createState() => _MyTripsState();
}

class _MyTripsState extends State<MyTrips> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<List<String>> trips = [];

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

          Widget DatePicker({TextEditingController controller, String label}) {
            controller.text = '$label Date';
            final format = DateFormat("yyyy-MM-dd");
            return DateTimeField(
              controller: controller,
              format: format,
              onShowPicker: (context, _) {
                return showDatePicker(
                    context: context,
                    firstDate: DateTime(DateTime.now().year),
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

  Widget TravelCard({List<String> tripData}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (context, _, __) => Trip(tripData: tripData)));
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  tripData[0],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                GestureDetector(
                    onTap: () {
                      print('Deleting Trip');
                    },
                    child: Icon(Icons.delete, color: Colors.black54))
              ]),
              SizedBox(height: 10),
              Text(
                '${tripData.length - 3} Travellers',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tripData[1], style: TextStyle(fontSize: 16)),
                  Text('-', style: TextStyle(fontSize: 16)),
                  Text(tripData[2], style: TextStyle(fontSize: 16))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /*
  * TODO: Fetch My Trips from MongoDB, and fill trips[]
  *
  * TripData: {
  *   tripName: '',
  *   from: '',
  *   to: '',
  *   travellers: [],
  *   tripId: null
  * }
  *
  * */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 235, 215, 1),
      appBar: AppBar(
        centerTitle: true,
        title: Text("My Trips"),
      ),
      body: ListView.builder(
        itemCount: trips.length,
        itemBuilder: (BuildContext context, int index) {
          return TravelCard(tripData: trips[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          createTripDialog(context).then((value) {
            if (value != null && value.length > 0) {
              setState(() {
                trips.add(value);
                /*
                * TODO: Add this Trip to My Trips in MongoDB
                * */
              });
            }
          });
        },
      ),
    );
  }
}
