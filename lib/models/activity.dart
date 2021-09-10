class Activity {
  String activity;
  String costPerHead;
  String payedBy;

  Activity(this.activity, this.costPerHead, this.payedBy);

  Activity.fromJSON(Map<String, dynamic> json) {
    activity = json['activity'];
    costPerHead = json['costPerHead'];
    payedBy = json['payedBy'];
  }

  // ignore: non_constant_identifier_names
  ActivityToJSON() {
    return {
      'activity': this.activity,
      'costPerHead': this.costPerHead,
      'payedBy': this.payedBy
    };
  }
}