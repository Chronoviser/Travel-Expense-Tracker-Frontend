import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api-handler/trip-handler.dart';
import 'package:frontend/models/activity.dart';
import 'package:frontend/models/trip.dart';

class TripDetail extends StatefulWidget {
  final Trip tripData;

  TripDetail({Key key, this.tripData}) : super(key: key);

  @override
  _TripDetailState createState() => _TripDetailState(
      tripData.id,
      tripData.tripName,
      tripData.from,
      tripData.to,
      tripData.travellers,
      tripData.activities);
}

class _TripDetailState extends State<TripDetail> {
  TripHandler tripHandler = new TripHandler();
  Trip currentTrip;
  bool updatesDone = false;
  bool allowOperations = false;
  String tripStatus = "Pending";

  _TripDetailState(id, tripName, from, to, travellers, activities) {
    currentTrip =
        new Trip.withActivity(id, tripName, from, to, travellers, activities);
  }

  Future<List<String>> createActivityDialog(BuildContext context) async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return await showDialog(
        context: context,
        builder: (context) {
          TextEditingController activityController = TextEditingController();
          String priceType = "perHead";
          TextEditingController priceController = TextEditingController();
          String whoPayed;

          Widget customTextField(
              {TextEditingController controller, String hintText}) {
            return TextFormField(
              controller: controller,
              validator: (value) {
                return value.isNotEmpty ? null : "Invalid Activity Name";
              },
              decoration: InputDecoration(hintText: hintText),
            );
          }

          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        customTextField(
                            controller: activityController,
                            hintText: 'Activity Name'),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: DropdownButton<String>(
                                value: priceType,
                                icon:
                                    const Icon(Icons.arrow_drop_down_outlined),
                                iconSize: 24,
                                elevation: 16,
                                onChanged: (newValue) {
                                  setState(() {
                                    priceType = newValue;
                                  });
                                },
                                items: <String>[
                                  'perHead',
                                  'Total'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                                width: 100,
                                child: TextFormField(
                                  controller: priceController,
                                  validator: (value) {
                                    return (value.isEmpty || value.length > 5)
                                        ? "Invalid Price"
                                        : null;
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText: 'Activity Price'),
                                ))
                          ],
                        ),
                        SizedBox(height: 10),
                        DropdownButton<String>(
                          hint: Text('Who Payed?'),
                          value: whoPayed,
                          icon: const Icon(Icons.arrow_drop_down_outlined),
                          iconSize: 24,
                          elevation: 16,
                          onChanged: (newValue) {
                            setState(() {
                              whoPayed = newValue;
                            });
                          },
                          items: [...currentTrip.travellers, 'dutch']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  )),
              actions: <Widget>[
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      List<String> activityData = [];
                      activityData
                          .add(activityController.text.toString().trim());
                      activityData.add(priceType);
                      activityData.add(priceController.text.toString().trim());
                      activityData.add(whoPayed);
                      Navigator.of(context).pop(activityData);
                    }
                  },
                )
              ],
            );
          });
        });
  }

  // ignore: non_constant_identifier_names
  Widget ActivityCard({Activity activityData}) {
    String _activity = activityData.activity;
    String _costPerHead = activityData.costPerHead;
    String _paidBy = activityData.payedBy;

    return Card(
      color: Color.fromRGBO(250, 235, 215, 1),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _activity,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              '₹ $_costPerHead /head',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                '💰 $_paidBy',
                style: TextStyle(fontSize: 16),
              ),
              allowOperations
                  ? GestureDetector(
                      onTap: () {
                        deleteActivity(activityData);
                      },
                      child: Icon(Icons.delete, color: Colors.black54))
                  : Container()
            ])
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, updatesDone);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text(currentTrip.tripName),
          actions: [
            Container(
                padding: EdgeInsets.all(5),
                alignment: Alignment.center,
                child: Text(tripStatus, style: TextStyle(color: Colors.green)))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Container(
                  color: Colors.black54,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("From: ${currentTrip.from}",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("To: ${currentTrip.to}",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('Travellers: ${currentTrip.travellers}',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: currentTrip.activities.reversed
                      .map<Widget>((activityData) =>
                          ActivityCard(activityData: activityData))
                      .toList(),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: allowOperations
            ? FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  createActivityDialog(context).then((value) {
                    if (value != null && value.length > 0) {
                      Activity activity =
                          new Activity(value[0], value[2], value[3]);
                      createActivity(activity);
                    }
                  });
                })
            : null,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    updateTripStatus();
  }

  updateTripStatus() {
    int a = DateTime.now().difference(DateTime.parse(currentTrip.from)).inDays;
    int b = DateTime.now().difference(DateTime.parse(currentTrip.to)).inDays;
    if (a >= 0 && b <= 0) {
      setState(() {
        tripStatus = "Day ${a + 1}";
        allowOperations = true;
      });
    } else if (b > 0) {
      setState(() {
        tripStatus = "Complete";
      });
    }
  }

  showNetworkError() {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Network Error!')));
  }

  createActivity(Activity activity) async {
    currentTrip.activities.add(activity);
    var response = await tripHandler.updateTrip(currentTrip);
    if (response)
      setState(() {
        updatesDone = true;
      });
    else {
      showNetworkError();
      currentTrip.activities.removeLast();
    }
  }

  deleteActivity(Activity activity) async {
    int index = currentTrip.activities.indexOf(activity);
    currentTrip.activities.removeAt(index);
    var response = await tripHandler.updateTrip(currentTrip);
    if (response)
      setState(() {
        updatesDone = true;
      });
    else {
      showNetworkError();
      currentTrip.activities.insert(index, activity);
    }
  }
}
