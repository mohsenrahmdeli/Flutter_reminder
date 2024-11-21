import 'package:flutter/material.dart';
import '../helper/helper.dart';
import '../services/notification_helper.dart';
import '../services/permission_handler.dart';
import 'add_edit_reminder.dart';
import 'reminder_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _reminders = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    requestNotificationPermissions();
    _loadReminders();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    try {
      final reminders = await SharedPreferencesHelper.getReminders();
      final now = DateTime.now();
      setState(() {
        _reminders = (reminders ?? []).map((reminder) {
          final reminderTime = DateTime.parse(reminder['reminderTime']);
          if (now.isAfter(reminderTime)) {
            reminder['isActive'] = 0;
          }
          return reminder;
        }).toList();
      });
      await SharedPreferencesHelper.saveReminders(_reminders);
    } catch (e) {
      print('Error loading reminders: $e');
      setState(() {
        _reminders = [];
      });
    }
  }

  Future<void> _toggleReminder(int id, bool isActive) async {
    final reminders = await SharedPreferencesHelper.getReminders();
    if (reminders != null) {
      final index = reminders.indexWhere((rem) => rem['id'] == id);
      if (index != -1) {
        reminders[index]['isActive'] = isActive ? 1 : 0;
        await SharedPreferencesHelper.saveReminders(reminders);
        setState(() {
          _reminders = reminders;
        });
      }
    }

    if (isActive) {
      try {
        final reminder = _reminders.firstWhere((rem) => rem['id'] == id);
        NotificationHelper.scheduleNotificaton(
          id,
          reminder['title'],
          reminder['category'],
          DateTime.parse(reminder['reminderTime']),
        );
      } catch (e) {
        print('Error scheduling notification: $e');
      }
    } else {
      try {
        NotificationHelper.cancelNotification(id);
      } catch (e) {
        print('Error canceling notification: $e');
      }
    }
  }

  Future<void> _deleteReminder(int id) async {
    final reminders = await SharedPreferencesHelper.getReminders();
    if (reminders != null) {
      reminders.removeWhere((rem) => rem['id'] == id);
      await SharedPreferencesHelper.saveReminders(reminders);
      setState(() {
        _reminders = reminders;
      });
    }
    NotificationHelper.cancelNotification(id);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off,
                      color: Colors.teal,
                      size: 50,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "No reminders found.\nAdd one by clicking the + button.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.teal,
                      ),
                    ),
                  ],
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
                      color: const Color.fromARGB(255, 255, 17, 1),
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
                    onDismissed: (direction) async {
                      try {
                        await _deleteReminder(reminder['id']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Reminder Deleted'),
                          ),
                        );
                      } catch (e) {
                        print('Error deleting reminder: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete reminder'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        _loadReminders();
                      }
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReminderDetailScreen(
                                reminderId: reminder['id'],
                              ),
                            ),
                          );
                        },
                        leading: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: DateTime.now().isAfter(DateTime.parse(
                                        reminder['reminderTime']))
                                    ? ColorTween(
                                            begin: Colors.red,
                                            end: Colors.transparent)
                                        .evaluate(_controller)
                                    : Colors.green,
                                shape: BoxShape.circle,
                              ),
                            );
                          },
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
                          },
                        ),
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
