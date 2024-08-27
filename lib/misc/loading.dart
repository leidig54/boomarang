import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, required this.message});

  final String message;

  @override
  State<LoadingScreen> createState() => _LoadinScreenState();
}

class _LoadinScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(
              height: 20,
            ),
            Text(widget.message),
          ],
        ),
      ),
    );
  }
}
