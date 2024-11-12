import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateTaskPage extends StatefulWidget {
  final Map<String, dynamic>? existingTask;

  const CreateTaskPage({super.key, this.existingTask});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      _titleController.text = widget.existingTask!['title'];
      _descriptionController.text = widget.existingTask!['description'];
      _dueDate = widget.existingTask!['dueDate'];
    }
  }

  // Save task
  void _saveTask() {
    final newTask = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'dueDate': _dueDate,
      'completed': false,
    };

    Navigator.pop(context, newTask);
  }

  Future<void> _selectDueDateTime(BuildContext context) async {
    // Show date picker first
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Show time picker if a date is selected
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate),
      );

      if (pickedTime != null) {
        setState(() {
          // Combine the selected date and time
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.existingTask != null ? 'Edit Task' : 'Create Task',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
              onPressed: () {
                _saveTask();
              },
              icon: const Icon(Icons.done))
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Task Title.',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Enter task description...',
                border: InputBorder.none,
              ),
              maxLines: null,
              // Allows unlimited lines
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontSize: 16),
              minLines: 18,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _selectDueDateTime(context),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 10),
                Text(DateFormat('MMM dd, yyyy - hh:mm a').format(_dueDate)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
