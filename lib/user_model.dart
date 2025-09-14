class UserModel {
  final String Name;
  final String Roomno;
  final String PhoneNo;
  final String? fcmToken;

  const UserModel({
    required this.Name,
    required this.Roomno,
    required this.PhoneNo,
    this.fcmToken
  });

  Map<String, dynamic> toJson() {
    return {
      "Name": Name,
      "Room No": Roomno,
      "Phone Number": PhoneNo,
      "fcmToken": fcmToken
    };
  }
}
