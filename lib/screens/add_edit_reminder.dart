import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/notification_helper.dart';
import 'home_screen.dart';

class AddEditReminder extends StatefulWidget {
  final int? reminderId;
  const AddEditReminder({super.key, this.reminderId});

  @override
  State<AddEditReminder> createState() => _AddEditReminderState();
}

class _AddEditReminderState extends State<AddEditReminder> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  String _category = 'Work';
  DateTime _reminderTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.reminderId != null) {
      fetchReminder();
    }
  }

  Future<void> fetchReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = prefs.getString('reminders');
    if (reminders != null) {
      final remindersList = jsonDecode(reminders) as List;
      final reminder = remindersList.firstWhere(
        (r) => r['id'] == widget.reminderId,
        orElse: () => null,
      ) as Map<String, dynamic>?;

      if (reminder != null) {
        setState(() {
          _titleController.text = reminder['title'];
          _descriptionController.text = reminder['description'];
          _category = reminder['category'];
          _reminderTime = DateTime.parse(reminder['reminderTime']);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.teal,
        ),
        backgroundColor: Colors.white,
        title: Text(
          widget.reminderId == null ? 'Add Reminder' : 'Edit Reminder',
          style: TextStyle(
            color: Colors.teal,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputCard(
                  label: 'Title',
                  icon: Icons.title,
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter Title',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      return value!.isEmpty ? 'Please enter a title' : null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                _buildInputCard(
                  label: 'Description',
                  icon: Icons.description,
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter Description',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      return value!.isEmpty ? 'Please Description' : null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                _buildInputCard(
                  label: 'Category',
                  icon: Icons.category,
                  child: DropdownButtonFormField(
                    value: _category,
                    dropdownColor: Colors.teal.shade50,
                    decoration: InputDecoration.collapsed(hintText: ''),
                    items: ['Work', 'Personal', 'Helath', 'Others'].map(
                      (category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _category = value;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                _buildDateTimePicker(
                  label: 'Date',
                  icon: Icons.calendar_today,
                  displayValue: DateFormat('yyy-MM-dd').format(_reminderTime),
                  onPressed: _selectDate,
                ),
                SizedBox(
                  height: 10,
                ),
                _buildDateTimePicker(
                  label: 'Time',
                  icon: Icons.access_time,
                  displayValue: DateFormat('hh:mm a').format(_reminderTime),
                  onPressed: _selectTime,
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _saveReminder,
                    child: Text('Save Reminder'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(
      {required String label, required IconData icon, required Widget child}) {
    return Card(
      elevation: 6,
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.teal,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(
      {required String label,
      required IconData icon,
      required String displayValue,
      required Function() onPressed}) {
    return Card(
      elevation: 6,
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.teal,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: TextButton(
          onPressed: onPressed,
          child: Text(
            displayValue,
            style: TextStyle(
              color: Colors.teal,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _reminderTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        _reminderTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _reminderTime.hour,
          _reminderTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      ),
    );
    if (picked != null) {
      setState(() {
        _reminderTime = DateTime(
          _reminderTime.year,
          _reminderTime.month,
          _reminderTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final reminders = prefs.getString('reminders');
      List remindersList = reminders != null ? jsonDecode(reminders) : [];

      final newReminder = {
        'id': widget.reminderId ??
            (DateTime.now().millisecondsSinceEpoch % 2147483647),
        'title': _titleController.text,
        'description': _descriptionController.text,
        'isActive': 1,
        'reminderTime': _reminderTime.toIso8601String(),
        'category': _category,
      };

      if (widget.reminderId == null) {
        remindersList.add(newReminder);
      } else {
        remindersList = remindersList.map((reminder) {
          if (reminder['id'] == widget.reminderId) {
            return newReminder;
          }
          return reminder;
        }).toList();
      }

      await prefs.setString('reminders', jsonEncode(remindersList));
      NotificationHelper.scheduleNotificaton(
        newReminder['id'] as int, // تبدیل به نوع int
        _titleController.text,
        _category,
        _reminderTime,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    }
  }
}
