import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Looks like you haven't clarified anything yet",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
              SizedBox(height: 20),
              Text(
                "Get started by sharing a link to the clarify app or paste a link here by tapping the link button below",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
