import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  Future<void> callFunction() async {
    final result = await FirebaseFunctions.instance
        .httpsCallable('triggerAdd')
        .call({"a": 8, "b": 6});

    print(result.data);
  }

  Future<void> sendPushNotification() async {
    final token = await FirebaseMessaging.instance.getToken();

    if (token == null) {
      print("No FCM token found");
      return;
    }

    final result = await FirebaseFunctions.instance
        .httpsCallable('sendPushNotification')
        .call({
          "token": token,
          "title": "Hello!",
          "body": "Notification from Firebase Cloud Function",
        });

    print(result.data);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Center(
              child: ElevatedButton(
                onPressed: callFunction,
                child: const Text("Add Numbers"),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: sendPushNotification,
                child: const Text("Notification"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
