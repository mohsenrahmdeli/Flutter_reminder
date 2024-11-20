import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../services/notification_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final reminders = await DbHelper.getReminders();
    setState(() {
      _reminders = reminders;
    });
  }

  Future<void> _toggleReminder(int id, bool isActive) async {
    await DbHelper.toggleReminder(id, isActive);
    if (isActive) {
      final reminder = _reminders.firstWhere((rem) => rem['id'] == id);
      NotificationHelper.scheduleNotificaton(id, reminder['title'],
          reminder['category'], DateTime.parse(reminder['reminderTime']));
    } else {
      NotificationHelper.cancelNotification(id);
    }
  }

  Future<void> _deleteReminder(int id) async {
    await DbHelper.deleteReminder(id);
    NotificationHelper.cancelNotification(id);
    _loadReminders();
  }

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
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
