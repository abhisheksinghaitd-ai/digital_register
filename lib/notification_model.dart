import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String roomNo;
  final String title;
  final String body;
  final DateTime? timestamp;
  final String status;
  final String phoneNo;
  final String? imageUrl;
  
  

  const NotificationModel({
    required this.roomNo,
    required this.title,
    required this.body,
    required this.status,
    this.timestamp,
    required this.phoneNo,
    this.imageUrl
    
  });

  Map<String, dynamic> toJson() {
    return {
      "Room No": roomNo,
      "title": title,
      "body": body,
      "timestamp": FieldValue.serverTimestamp(),
      "status":status,
      "phoneNo":phoneNo,
      "imageUrl":imageUrl
      
      

    };
  }

 factory NotificationModel.fromJson(Map<String, dynamic> json) {
  return NotificationModel(
    roomNo: json["Room No"] ?? '',
    title: json["title"] ?? '',
    body: json["body"] ?? '',
    timestamp: json["timestamp"] != null
        ? (json["timestamp"] as Timestamp).toDate()
        : null, // Safe fallback
        status: json['status'] ?? '',
        phoneNo: json["phoneNo"] ?? '',
        imageUrl: json['imageUrl'] ?? ''
        
  );
}

}
