class VisitorModel{
  final String name;
  final String roomNo;
  final String purpose;
  final String phoneNo;
  final String? imageUrl;

  const VisitorModel({
    required this.name,
    required this.roomNo,
    required this.purpose,
    required this.phoneNo,
    this.imageUrl


  });

  toJson(){
    return {
      "Visitor Name":name,
      "Room No":roomNo,
      "Purpose":purpose,
      "phoneNo":phoneNo,
      "imageUrl":imageUrl
    };
  }

}