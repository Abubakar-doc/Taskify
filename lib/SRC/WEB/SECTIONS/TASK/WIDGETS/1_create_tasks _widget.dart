import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/WIDGETS/hoverable_stretched_aqua_button.dart';
import 'package:taskify/THEME/theme.dart';

class CreateTasksWidget extends StatefulWidget {
  const CreateTasksWidget({super.key});

  @override
  _CreateTasksWidgetState createState() => _CreateTasksWidgetState();
}

class _CreateTasksWidgetState extends State<CreateTasksWidget> {
  final TextEditingController _departmentNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
              'Create Tasks',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Task Tittle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _departmentNameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: customLightGrey,
                hintText: 'Task Tittle',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
              ),
              style: const TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Task Tittle';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _departmentNameController,
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
            const SizedBox(height: 16),
            HoverableElevatedButton(
              text: 'Create Task',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Implement Create Department logic here
                  final departmentName = _departmentNameController.text;
                  // Perform the create department logic with departmentName
                  print('Task Created: $departmentName');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _departmentNameController.dispose();
    super.dispose();
  }
}
