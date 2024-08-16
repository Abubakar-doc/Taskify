import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taskify/SRC/COMMON/SERVICES/task.dart';
import 'package:taskify/SRC/COMMON/UTILS/Utils.dart';
import 'package:taskify/SRC/COMMON/MODEL/task.dart';
import 'package:taskify/SRC/WEB/WIDGETS/hoverable_stretched_aqua_button.dart';
import 'package:taskify/THEME/theme.dart';

class CreateTasksWidget extends StatefulWidget {
  const CreateTasksWidget({super.key});

  @override
  _CreateTasksWidgetState createState() => _CreateTasksWidgetState();
}

class _CreateTasksWidgetState extends State<CreateTasksWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TaskService _taskService = TaskService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Task',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Task Title',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: customLightGrey,
                hintText: 'Task Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
              ),
              style: const TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Task Title';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                filled: true,
                fillColor: customLightGrey,
                hintText: 'Task Description (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 16),
            HoverableElevatedButton(
              text: 'Create Task',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _createTask,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final task = Task(
          id: '', // Assuming ID is auto-generated or handled by the backend
          title: _titleController.text,
          description: _descriptionController.text,
          createdAt: Timestamp.now(), // Use Timestamp
          updatedAt: Timestamp.now(), // Use Timestamp
        );

        await _taskService.createTask(task);

        // Clear controllers
        _titleController.clear();
        _descriptionController.clear();

        Utils().SuccessSnackBar(
          context,
          "Task has been successfully created!",
        );
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to create task: $e';
        });
        Utils().ErrorSnackBar(
          context,
          'Failed to create task: $e',
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
