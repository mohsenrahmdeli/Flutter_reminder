import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../services/notification_helper.dart';
import 'add_edit_reminder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
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
        body: _reminders.isEmpty
            ? Center(
                child: Text(
                  "No reminder Found",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.teal,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  final reminder = _reminders[index];
                  return Dismissible(
                    key: Key(reminder['id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.redAccent,
                      padding: EdgeInsets.only(right: 20),
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await _showDeleteConfirmationDialog(context);
                    },
                    onDismissed: (direction) {
                      _deleteReminder(reminder['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Reminder Delered',
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.teal.shade50,
                      elevation: 6,
                      margin: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        onTap: (){
                          // Navigator.push(context, 
                          // MaterialPageRoute(builder: (context)=> ReminderDetailScreen()));
                        },
                        leading: Icon(
                          Icons.notifications,
                          color: Colors.teal,
                        ),
                        title: Text(
                          reminder['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          'category: ${reminder['category']}',
                        ),
                        trailing: Switch(
                            value: reminder['isActive'] == 1,
                            activeColor: Colors.teal,
                            inactiveTrackColor: Colors.white,
                            inactiveThumbColor: Colors.black,
                            onChanged: (value) {
                              _toggleReminder(reminder['id'], value);
                            },),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddEditReminder()));
          },
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Delete Reminder'),
        content: Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      );
    },
  );
}
