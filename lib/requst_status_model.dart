class RequstStatusModel {
  String status;
  String time;
  String title;   // instead of purpose
  String body;    // instead of name
  String reason;
  String? phoneNo;

  RequstStatusModel({
    required this.status,
    required this.time,
    required this.title,
    required this.body,
    required this.reason,
     this.phoneNo

  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'time': time,
      'title': title,
      'body': body,
      'reason': reason,
      'phoneNo' : phoneNo ?? ''
    };
  }

  factory RequstStatusModel.fromJson(Map<String, dynamic> json) {
    return RequstStatusModel(
      status: json['status'] ?? '',
      time: json['time'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      reason: json['reason'] ?? '',
      phoneNo: json['phoneNo'] 
    );
  }
}
