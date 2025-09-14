import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_register/visitor_entry_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';


class AdminMain extends StatelessWidget {

  const AdminMain({super.key});


  Future<void> _makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else {
    throw 'Could not launch $phoneNumber';
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel"),
      actions: [TextButton(onPressed: (){
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VisitorEntryPage(),
                            ),
                          );
                        }, child: Icon(Icons.add))],),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Notifications')
            .orderBy('timestamp', descending: true) // latest first
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No requests found",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id; // <-- get document ID

              final title = data['title'] ?? 'No Title';
              final body = data['body'] ?? 'No Body';
              final status = data['status'] ?? 'Pending';
              final reason = (data['reason'] != null && data['reason'].toString().isNotEmpty)
                  ? data['reason']
                  : 'N/A';
              final time = data['timestamp'] ?? '';
              final phoneNo = data['phoneNo'] ?? 'No Phone No';
              final roomNo = data['Room No'] ?? 'No Room No';
              final String? imageUrl = data["imageUrl"];

              

              return Card(
                margin: const EdgeInsets.all(12),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      if(imageUrl!=null && imageUrl.isNotEmpty)
                     

                  


                      Text(
                        "Request Details",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 20),
                          CircleAvatar(
                         radius: 80,
                        backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                        ?NetworkImage(imageUrl)
                        : null,
                        child: (imageUrl == null || imageUrl.isEmpty)
                        ? const Icon(Icons.person, size: 40)
                        : null,
),
                     
                      ListTile(title:Text("Alert: $title",style: GoogleFonts.poppins(color:Colors.white,fontWeight:FontWeight.bold,fontSize: 16)),leading: Icon(Icons.alarm), ),
                      
                      ListTile(title:Text("Details: $body",style: GoogleFonts.poppins(color:Colors.white,fontWeight:FontWeight.bold,fontSize: 16)),leading: Icon(Icons.description), ),
                     ListTile(title:Text("Current Status: $status",style: GoogleFonts.poppins(color:Colors.red,fontWeight:FontWeight.bold,fontSize: 16)),leading: Icon(Icons.pending), ),
                      ListTile(title:Text("Specified Reason: $reason",style: GoogleFonts.poppins(color:Colors.blue,fontWeight:FontWeight.bold,fontSize: 16)),leading: Icon(Icons.messenger_rounded), ),
                      ListTile(title: Text('Room No. $roomNo',style: GoogleFonts.poppins(color:Colors.white,fontWeight:FontWeight.bold,fontSize: 16)),leading: Icon(Icons.room),),
                      ListTile(title: Text('Actions'),leading: Icon(Icons.add_task),),
                      
                      
                      
                      // Text("Time: $time"),
                      const SizedBox(height: 10),

                      Padding(padding: EdgeInsets.all(10),
                      child:Row( mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          ElevatedButton.icon(style:ElevatedButton.styleFrom(backgroundColor: Colors.transparent),onPressed: () async{
                            showDialog(context: context, builder: (BuildContext context){
                              return AlertDialog(title: Text('Are you sure?'),
                              content: Text('Please select'),
                              actions: [
                                TextButton(onPressed: () async {
                                 await FirebaseFirestore.instance.collection("admin notifier")
                                .doc(docId).delete();

                                }, child: Text('Yes'), ),
                                TextButton(onPressed: (){
                                  Navigator.of(context).pop();
                                }, child: Text('Cancel'))
                              ],
                              );
                            });
                      
                      }, label: Text('Remove',style: GoogleFonts.poppins(color:Colors.red,fontWeight:FontWeight.bold,fontSize: 16)),icon: Icon(Icons.delete,color: Colors.red,),),

                      SizedBox(width: 10,),


                       ElevatedButton.icon(style:ElevatedButton.styleFrom(backgroundColor: Colors.transparent),onPressed: () async{
                          _makePhoneCall(phoneNo);


                      }, label: Text('Call Resident',style: GoogleFonts.poppins(color:Colors.white,fontWeight:FontWeight.bold,fontSize: 16)),icon: Icon(Icons.call,color: Colors.white,),)
                      
                      ]))
                      
                    ],
                  ),
                  
                  
                ),
                
              );
              
            },
          );
        },
      ),
    );
  }
}
