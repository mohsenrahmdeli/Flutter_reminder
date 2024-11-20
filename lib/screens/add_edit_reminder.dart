import 'package:flutter/material.dart';
import 'package:reminder_app/database/db_helper.dart';

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
    // TODO: implement initState
    super.initState();
    if (widget.reminderId != null) {
      fetchReminder();
    }
  }

  Future<void> fetchReminder() async {
    try {
      final data = await DbHelper.getRemindersBuId(widget.reminderId!);
      if (data != null) {
        _titleController.text = data['title'];
        _descriptionController.text = data['description'];
        _category = data['category'];
        _reminderTime = DateTime.parse(data['reminderTime']);
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
