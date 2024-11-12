import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:intl/intl.dart';
import 'createTask.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> tasks = [];

  // Add new task
  void _addTask(Map<String, dynamic> newTask) {
    setState(() {
      tasks.add(newTask);
      tasks.sort((a, b) => a['dueDate'].compareTo(b['dueDate']));
    });
  }

  // Edit task
  void _editTask(int index, Map<String, dynamic> editedTask) {
    setState(() {
      tasks[index] = editedTask;
      tasks.sort((a, b) => a['dueDate'].compareTo(b['dueDate']));
    });
  }

  // Delete task
  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  // Toggle task completion
  void _toggleCompletion(int index) {
    setState(() {
      tasks[index]['completed'] = !tasks[index]['completed'];
    });
  }

  // Navigate to Create Task Page
  Future<void> _navigateToCreateTask([int? index]) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => CreateTaskPage(
          existingTask: index != null ? tasks[index] : null,
        ),
      ),
    );

    if (result != null) {
      index != null ? _editTask(index, result) : _addTask(result);
    }
  }

  // Get categorized tasks for the given date
  List<Map<String, dynamic>> _getTasksForDate(DateTime date) {
    return tasks
        .where((task) =>
            DateFormat('yyyy-MM-dd').format(task['dueDate']) ==
            DateFormat('yyyy-MM-dd').format(date))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final todayTasks = _getTasksForDate(DateTime.now());
    final tomorrowTasks =
        _getTasksForDate(DateTime.now().add(const Duration(days: 1)));
    final upcomingTasks = tasks.where((task) {
      final taskDate = task['dueDate'];
      return taskDate.isAfter(DateTime.now().add(const Duration(days: 1)));
    }).toList();
    final pastTasks = tasks.where((task) {
      final taskDate = task['dueDate'];
      return taskDate
          .isBefore(DateTime.now().subtract(const Duration(days: 1)));
    }).toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'To-Do List',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 50,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Nothing to do here. Add a new task to get Started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (pastTasks.isNotEmpty) _buildTaskSection('Past', pastTasks),
                if (todayTasks.isNotEmpty)
                  _buildTaskSection('Today', todayTasks),
                if (tomorrowTasks.isNotEmpty)
                  _buildTaskSection('Tomorrow', tomorrowTasks),
                if (upcomingTasks.isNotEmpty)
                  _buildTaskSection('Upcoming', upcomingTasks),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateTask(),
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }

  // Task Section Widget
  Widget _buildTaskSection(
      String title, List<Map<String, dynamic>> sectionTasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...sectionTasks.map((task) {
          final index = tasks.indexWhere((element) => element == task);
          return _buildTaskItem(task, index);
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  // for build Task Items
  Widget _buildTaskItem(Map<String, dynamic> task, int index) {
    return SwipeActionCell(
      backgroundColor: Colors.white,
      key: ValueKey(index),
      trailingActions: [
        SwipeAction(
          title: 'Delete',
          onTap: (CompletionHandler handler) async {
            await handler(false);
            await _confirmDelete(context, index);
          },
          color: Colors.red,
          icon: const Icon(Icons.delete, color: Colors.white),
        ),
      ],
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          tileColor: task['completed'] ? Colors.black12 : Colors.white,
          onTap: () {
            _navigateToCreateTask(index);
          },
          leading: Checkbox(
            value: task['completed'],
            shape: const CircleBorder(),
            side: const BorderSide(width: 2.0, color: Colors.blue),
            onChanged: (_) => _toggleCompletion(index),
          ),
          title: Text(
            task['title'],
            style: TextStyle(
              fontSize: 18,
              decoration: task['completed']
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: Text(
            DateFormat('MMM dd, yyyy - hh:mm a').format(task['dueDate']),
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: const Icon(CupertinoIcons.chevron_forward),
        ),
      ),
    );
  }


  Future<void> _confirmDelete(BuildContext context, index) async {
    final bool shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete) {
      _deleteTask(index);
    }
  }
}
