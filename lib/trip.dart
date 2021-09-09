import 'package:flutter/material.dart';

class Trip extends StatefulWidget {
  final List<String> tripData;
  final List<String> travellers = [];

  Trip({Key key, this.tripData}) : super(key: key) {
    for (int i = 3; i < tripData.length; i++) {
      travellers.add(tripData[i]);
    }
  }

  @override
  _TripState createState() =>
      _TripState(tripData[0], tripData[1], tripData[2], travellers);
}

class _TripState extends State<Trip> {
  final String tripName;
  final String from;
  final String to;
  final List<String> travellers;

  _TripState(this.tripName, this.from, this.to, this.travellers);

  Future<List<String>> createActivityDialog(BuildContext context) async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return await showDialog(
        context: context,
        builder: (context) {
          TextEditingController activityController = TextEditingController();
          String priceType = "per Head";
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
                                  'per Head',
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
                          items: [...travellers, 'dutch']
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

  List<List<String>> activities = [];

  Widget ActivityCard({List<String> activityData}) {
    String _activity = activityData[0];
    String _priceType = activityData[1];
    String _costPerHead = activityData[2];
    String _paidBy = activityData[3];

    if (_priceType == "Total") {
      _costPerHead =
          (double.parse(activityData[2]) / (travellers.length)).toString();
    }

    return Card(
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
              GestureDetector(
                  onTap: () {
                    print('Deleting ACtivity');
                    /*
                    * TODO: Remove this Activity from database
                    * */
                  },
                  child: Icon(Icons.delete, color: Colors.black54))
            ])
          ],
        ),
      ),
    );
  }

  /*
  * TODO: Fetch Trip Activities Data from MongoDB, and fill activties[]
  *
  * ActivityData: {
  *   activity: '',
  *   costPerHead: '',
  *   paidBy: ''
  * }
  *
  * */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 235, 215, 1),
      appBar: AppBar(
        centerTitle: true,
        title: Text(tripName),
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
                    Text("From: $from",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("To: $to",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Travellers: $travellers',
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
                children: activities
                    .map<Widget>((activityData) =>
                        ActivityCard(activityData: activityData))
                    .toList(),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            createActivityDialog(context).then((value) {
              if (value != null && value.length > 0) {
                setState(() {
                  activities.add(value);
                  /*
                  * TODO: Add this Activity to Activities in MongoDB
                  * */
                });
              }
            });
          }),
    );
  }
}
