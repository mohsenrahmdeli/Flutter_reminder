import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Reminder',
            style: TextStyle(
              color: Colors.teal,
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.teal,
          ),
        ),
      ),
    );
  }
}
