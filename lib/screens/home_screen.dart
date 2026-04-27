import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shallutask/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _listenForegroundMessages();
  }

  Future<void> _requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        showLocalNotification(notification.title, notification.body);
      }
    });
  }

  Future<void> _sendPushNotification() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No FCM token — grant notification permission'),
          ),
        );
      }
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseFunctions.instance
          .httpsCallable('sendPushNotification')
          .call({
            "token": token,
            "title": "Hello!",
            "body": "Notification from Firebase Cloud Function",
          });
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _callAddFunction() async {
    final result = await FirebaseFunctions.instance
        .httpsCallable('triggerAdd')
        .call({"a": 8, "b": 6});
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Result: ${result.data}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Demo')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _callAddFunction,
              child: const Text('Add Numbers'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _sendPushNotification,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send Push Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
