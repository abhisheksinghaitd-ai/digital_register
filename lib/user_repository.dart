// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_register/requst_status_model.dart';
import 'package:digital_register/user_model.dart';
import 'package:digital_register/visitor_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_functions/cloud_functions.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  Future<void> updateFcmToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _db.collection("Users").doc(userId).update({"fcmToken": token});
      print("Updated FCM token for $userId");
    }
  }

  Future<void> updateAdminNotifierReason(String docId, String reason) async {
    await _db
        .collection('admin notifier')
        .doc(docId)
        .update({'reason': reason});
  }

  // CREATE USER
  Future<String> createUser(UserModel user) async {
    try {
      DocumentReference docRef =
          await _db.collection("Users").add(user.toJson());
      String docId = docRef.id;
      Get.snackbar(
        "Success",
        "The data has been saved!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.3),
        colorText: Colors.white,
      );
      return docId;
    } catch (error) {
      Get.snackbar(
        "Error",
        "Something went wrong: $error",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.3),
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  Future<String> createVisitor(VisitorModel visitor) async {
    try {
      // Save visitor
      DocumentReference docRef =
          await _db.collection("Visitor").add(visitor.toJson());

      // Create notification
      await createNotification(
        roomNo: visitor.roomNo,
        title: "Visitor Arrived",
        body: "${visitor.name} is here for ${visitor.purpose}",
        phoneNo: visitor.phoneNo,
        imageUrl: visitor.imageUrl
        
      );

      Get.snackbar(
        "Success",
        "The visitor has been saved and the resident notified!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.3),
        colorText: Colors.white,
      );

      return docRef.id;
    } catch (error) {
      Get.snackbar(
        "Error",
        "Something went wrong: $error",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.3),
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  Future<String> createAdminNotifier(RequstStatusModel resident) async {
    try {
      DocumentReference docRef =
          await _db.collection("admin notifier").add(resident.toJson());

      Get.snackbar(
        "Success",
        "The visitor has been saved and the resident notified!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.3),
        colorText: Colors.white,
      );

      return docRef.id;
    } catch (error) {
      Get.snackbar(
        "Error",
        "Something went wrong: $error",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.3),
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  // GET USER BY ID
  Future<UserModel> getUserById(String docId) async {
    try {
      final doc = await _db.collection("Users").doc(docId).get();

      if (!doc.exists) {
        throw Exception("User with docId $docId not found");
      }

      final data = doc.data();
      if (data == null) throw Exception("User data is empty for $docId");

      return UserModel(
        Name: data['Name'] ?? 'No Name',
        Roomno: data['Room No'] ?? 'No Room',
        PhoneNo: data['Phone Number'] ?? 'No Phone',
        fcmToken: data['fcmToken'] ?? 'No FcmToken',
      );
    } catch (e, st) {
      print("Error in getUserById: $e");
      print(st);
      rethrow;
    }
  }

  // GET ADMIN NOTIFIER BY ID
  Future<RequstStatusModel> getAdminById(String docId) async {
    try {
      final doc = await _db.collection("admin notifier").doc(docId).get();

      if (!doc.exists) {
        throw Exception("Admin notifier with docId $docId not found");
      }

      final data = doc.data();
      if (data == null) {
        throw Exception("Admin notifier data empty for $docId");
      }

      return RequstStatusModel(
        status: data['status'] ?? '',
        title: data['title'] ?? '',
        body: data['body'] ?? '',
        reason: data['reason'] ?? '',
        phoneNo: data['phoneNo'] ?? '',
        time: data['time'] ?? ''
      );
    } catch (e, st) {
      print("Error in getAdminById: $e");
      print(st);
      rethrow;
    }
  }

  // GET VISITOR BY ID
  Future<VisitorModel> getVisitorById(String docId) async {
    try {
      final doc = await _db.collection("Visitor").doc(docId).get();

      if (!doc.exists) {
        throw Exception("Visitor with docId $docId not found");
      }

      final data = doc.data();
      if (data == null) throw Exception("Visitor data empty for $docId");

      return VisitorModel(
        name: data['Visitor Name'] ?? 'No Visitor',
        roomNo: data['Room No'] ?? 'No Room',
        purpose: data['Purpose'] ?? 'No Purpose',
        phoneNo: data['phoneNo'] ?? 'No Phone Number',
        
      );
    } catch (e, st) {
      print("Error in getVisitorById: $e");
      print(st);
      rethrow;
    }
  }

  // SEND PUSH
  Future<void> sendPushMessage(
      String token, String title, String body) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('sendPushMessage');
      await callable.call({
        'token': token,
        'title': title,
        'body': body,
      });
    } catch (e) {
      print("Error sending push notification: $e");
    }
  }

  // SEARCH USERS
  Future<List<UserModel>> searchUsersByNameOrRoom(String query) async {
    print('DEBUG: searchUsersByNameOrRoom called with "$query"');
    final q = query.trim();
    if (q.isEmpty) return [];

    try {
      final FieldPath roomField = FieldPath(['Room No']);
      final FieldPath nameField = FieldPath(['Name']);
      final FieldPath phoneField = FieldPath(['Phone Number']);

      final roomSnapshot = await _db
          .collection("Users")
          .where(roomField, isGreaterThanOrEqualTo: q)
          .where(roomField, isLessThanOrEqualTo: '$q\uf8ff')
          .get();

      final nameSnapshot = await _db
          .collection("Users")
          .where(nameField, isGreaterThanOrEqualTo: q)
          .where(nameField, isLessThanOrEqualTo: '$q\uf8ff')
          .get();

      final numberSnapshot = await _db
          .collection("Users")
          .where(phoneField, isGreaterThanOrEqualTo: q)
          .where(phoneField, isLessThanOrEqualTo: '$q\uf8ff')
          .get();

      final Map<String, UserModel> merged = {};

      for (final d in roomSnapshot.docs) {
        final data = d.data();
        merged[d.id] = UserModel(
          Name: data['Name'] ?? 'No Name',
          Roomno: data['Room No'] ?? 'No Room',
          PhoneNo: data['Phone Number'] ?? 'No Phone',
        );
      }

      for (final d in nameSnapshot.docs) {
        final data = d.data();
        merged[d.id] = UserModel(
          Name: data['Name'] ?? 'No Name',
          Roomno: data['Room No'] ?? 'No Room',
          PhoneNo: data['Phone Number'] ?? 'No Phone',
        );
      }

      for (final d in numberSnapshot.docs) {
        final data = d.data();
        merged[d.id] = UserModel(
          Name: data['Name'] ?? 'No Name',
          Roomno: data['Room No'] ?? 'No Room',
          PhoneNo: data['Phone Number'] ?? 'No Phone',
        );
      }

      return merged.values.toList();
    } catch (e, st) {
      print('searchUsersByNameOrRoom ERROR: $e\n$st');
      return [];
    }
  }

  // CREATE NOTIFICATION
  Future<String> createNotification({
    required String roomNo,
    required String title,
    required String body,
    required String phoneNo,
    String? imageUrl
  }) async {
    try {
      final notificationData = {
        "Room No": roomNo,
        "title": title,
        "body": body,
        "timestamp": FieldValue.serverTimestamp(),
        "phoneNo": phoneNo,
        "imageUrl":imageUrl
      };

      DocumentReference docRef =
          await _db.collection("Notifications").add(notificationData);

      print("Notification added with ID: ${docRef.id}");

      final query = await _db
          .collection("Users")
          .where("Room No", isEqualTo: roomNo)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final userDoc = query.docs.first;
        final token = userDoc.data()["fcmToken"];
        if (token != null && token.isNotEmpty) {
          await sendPushMessage(token, title, body);
        } else {
          print("No FCM token found for this resident");
        }
      }

      return docRef.id;
    } catch (error) {
      print("Error adding notification: $error");
      rethrow;
    }
  }
}
