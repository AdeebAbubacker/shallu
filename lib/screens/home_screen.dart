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
          ],
        ),
      ),
    );
  }
}
