import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_register/user_model.dart';
import 'package:digital_register/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'requst_status_model.dart';

class ResidentmainuiPage extends StatefulWidget {
  final String docId;
  final dynamic phoneNo;
  const ResidentmainuiPage({
    super.key,
    required this.docId,
    required this.phoneNo,
  });

  @override
  State<ResidentmainuiPage> createState() => _ResidentmainuiPageState();
}

class _ResidentmainuiPageState extends State<ResidentmainuiPage> {
  final Box taskBoxresident = Hive.box('residenttasks');
  Timer? _timer;
  int _start = 180;

  late Future<UserModel> _userFuture;
  late String _roomNo;
  late String _userName;
  late String phoneNo;
  bool _isUserLoaded = false;

  void startTimer() {
    _start = 180;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _userFuture = UserRepository.instance.getUserById(widget.docId);
    _userFuture.then((user) {
      setState(() {
        _roomNo = user.Roomno;
        _userName = user.Name;
        phoneNo = user.PhoneNo;
        _isUserLoaded = true;
      });
    });
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUserLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldLeave = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirm Exit'),
              content: const Text('Are you sure you want to EXIT?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            ),
          );

          if (shouldLeave == true) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("$_userName - Room $_roomNo"),
        ),
        
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Notifications') 
              .where('Room No', isEqualTo: _roomNo)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No requests yet"));
            }

            final docs = snapshot.data!.docs;
            

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final request = RequstStatusModel.fromJson(data);
                final String?  imageUrl = data['imageUrl'] ?? '';
                return NotificationCardWidget(
                  request: request,
                  docId: docs[index].id,
                  imageUrl: imageUrl,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ------------------ Notification Card ------------------

class NotificationCardWidget extends StatefulWidget {
  final RequstStatusModel request;
  final String docId;
  final String? imageUrl;

  const NotificationCardWidget({
    super.key,
    required this.request,
    required this.docId,
    this.imageUrl,
  });

  @override
  State<NotificationCardWidget> createState() => _NotificationCardWidgetState();
}


class _NotificationCardWidgetState extends State<NotificationCardWidget> {
  late String status;
  late String reason;
  late String phone;
  late String?imageUrl;
  

  @override
  void initState() {
    super.initState();
    status = widget.request.status;
    reason = widget.request.reason;
    phone = widget.request.phoneNo ?? '';
    imageUrl = widget.imageUrl;
    
  }

  @override
  Widget build(BuildContext context) {
    bool approved = status == 'Approved';
    bool rejected = status == 'Rejected';

    return 

    Card(
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(backgroundImage: imageUrl!=null?NetworkImage(imageUrl!): null,
            radius: 80,
                        child: (imageUrl == null || imageUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 80)
                        : null,),
            ListTile(title: Text(widget.request.title,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),leading:Icon(Icons.person) ,),
            ListTile(title: Text(widget.request.body,style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),leading: Icon(Icons.location_pin),),
            ListTile(title: Text("Status: $status",style: GoogleFonts.poppins(color:Colors.white,fontWeight:FontWeight.bold,fontSize: 16)),leading: Icon(Icons.pending),),
            Visibility(visible:status=='Rejected',child:ListTile(title: Text("Reason: $reason",style: GoogleFonts.poppins(color:Colors.white,fontWeight:FontWeight.bold,fontSize: 16)),leading: Icon(Icons.messenger_rounded),)),
           
            ListTile(title: Text("Time: ${widget.request.time}"),leading: Icon(Icons.timer),),
            const SizedBox(height: 10),

            // Approve / Reject buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!approved && !rejected)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    onPressed: () async {
                      setState(() => status = 'Approved');
                      await FirebaseFirestore.instance
                          .collection('Notifications')
                          .doc(widget.docId)
                          .update({
                        'status': 'Approved',
                        'phoneNo': phone,
                      });
                    },
                    label: const Text("Approve"),
                  ),
                if (!approved && !rejected)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cancel),
                    onPressed: () async {
                      setState(() => status = 'Rejected');
                      await FirebaseFirestore.instance
                          .collection('Notifications')
                          .doc(widget.docId)
                          .update({
                        'status': 'Rejected',
                        'phoneNo': phone,
                      });
                    },
                    label: const Text("Reject"),
                  ),
                if (approved) const Text("✅ Approved"),
                if (rejected) const Text("❌ Rejected"),
              ],
            ),

            if (rejected)
              reason.isNotEmpty
                  ? Text(reason)
                  : Column(
                      children: [
                        _buildReasonButton("I’m not home"),
                        _buildReasonButton("I’m busy"),
                        _buildReasonButton("Family Emergency"),
                        _buildReasonButton("Out of Town"),
                        _buildReasonButton("Other"),
                      ],
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonButton(String r) {
    return TextButton(
      onPressed: () async {
        setState(() => reason = r);
        await FirebaseFirestore.instance
            .collection('admin notifier')
            .doc(widget.docId)
            .update({'reason': r, 'phoneNo': phone});
      },
      child: Text(r),
    );
  }
}
