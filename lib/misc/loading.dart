import 'package:flutter/material.dart';

// TODO: replace current loading screens with this
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(
            height: 20,
          ),
          Text(widget.message),
        ],
      ),
    );
  }
}
