import 'package:flutter/material.dart';
import 'package:taskify/THEME/theme.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:taskify/SRC/WEB/SERVICES/task.dart';
import 'package:taskify/SRC/WEB/MODEL/task.dart';

class AssignTasksToMembersWidget extends StatefulWidget {
  const AssignTasksToMembersWidget({super.key});

  @override
  _AssignTasksToMembersWidgetState createState() => _AssignTasksToMembersWidgetState();
}

class _AssignTasksToMembersWidgetState extends State<AssignTasksToMembersWidget> {
  final TaskService _taskService = TaskService();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _taskDescriptionController = TextEditingController();
  final TextEditingController _memberController = TextEditingController();
  final TextEditingController _memberEmailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Task> taskList = [];
  List<Map<String, String>> memberList = [
    {'name': 'John Doe', 'email': 'john.doe@example.com'},
    {'name': 'Jane Smith', 'email': 'jane.smith@example.com'},
    {'name': 'Ada Johnson', 'email': 'ada.johnson@example.com'},
    {'name': 'Bhalu Johnson', 'email': 'bhalu.johnson@example.com'},
  ];

  Task? selectedTask;
  Map<String, String> selectedMember = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _taskService.getTasksStream().listen((tasks) {
      setState(() {
        taskList = tasks;
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    _taskDescriptionController.dispose();
    _memberController.dispose();
    _memberEmailController.dispose();
    super.dispose();
  }

  void handleCancel() {
    setState(() {
      _taskController.clear();
      _taskDescriptionController.clear();
      _memberController.clear();
      _memberEmailController.clear();
      selectedTask = null;
      selectedMember = {};
    });
  }

  List<String> getTaskSuggestions(String query) {
    if (isLoading) {
      return ['Loading...'];
    } else if (taskList.isEmpty) {
      return ['No tasks found'];
    }
    return taskList
        .where((task) => task.title.toLowerCase().contains(query.toLowerCase()))
        .map((task) => task.title)
        .toList();
  }

  List<Map<String, String>> getMemberSuggestions(String query) {
    return memberList
        .where((member) => member['name']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

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
              'Assign Task to Members',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Task',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            DropDownSearchFormField(
              textFieldConfiguration: TextFieldConfiguration(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: customLightGrey,
                  hintText: 'Search Task',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                ),
                controller: _taskController,
              ),
              suggestionsCallback: (pattern) {
                return getTaskSuggestions(pattern);
              },
              itemBuilder: (context, String suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              itemSeparatorBuilder: (context, index) {
                return const Divider();
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (String suggestion) {
                if (suggestion != 'Loading...' && suggestion != 'No tasks found') {
                  final task = taskList.firstWhere((task) => task.title == suggestion);
                  setState(() {
                    selectedTask = task;
                    _taskController.text = suggestion;
                    _taskDescriptionController.text = task.description ?? '';
                  });
                }
              },
              displayAllSuggestionWhenTap: true,
              validator: (value) {
                if (value == null || value.isEmpty || value == 'Loading...' || value == 'No tasks found') {
                  return 'Please select a Task';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _taskDescriptionController,
              enabled: false, // Disable typing
              decoration: InputDecoration(
                filled: true,
                fillColor: customLightGrey,
                hintText: 'Task Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Member',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            DropDownSearchFormField(
              textFieldConfiguration: TextFieldConfiguration(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: customLightGrey,
                  hintText: 'Search Member',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                ),
                controller: _memberController,
              ),
              suggestionsCallback: (pattern) {
                return getMemberSuggestions(pattern)
                    .map((member) => member['name']!)
                    .toList();
              },
              itemBuilder: (context, String suggestion) {
                final member = memberList.firstWhere((member) => member['name'] == suggestion);
                return ListTile(
                  title: Text(suggestion),
                  subtitle: Text(member['email']!),
                );
              },
              itemSeparatorBuilder: (context, index) {
                return const Divider();
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (String suggestion) {
                final member = memberList.firstWhere((member) => member['name'] == suggestion);
                setState(() {
                  selectedMember = member;
                  _memberController.text = member['name']!;
                  _memberEmailController.text = member['email']!;
                });
              },
              displayAllSuggestionWhenTap: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a member';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _memberEmailController,
              enabled: false, // Disable typing
              decoration: InputDecoration(
                filled: true,
                fillColor: customLightGrey,
                hintText: 'Member Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final task = _taskController.text;
                              final member = _memberController.text;
                              final memberEmail = _memberEmailController.text;
                              // Perform the add member logic with task, member, and memberEmail
                              print('Member Added: $member to Task: $task with Email: $memberEmail');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: customAqua,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Assign Task',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: handleCancel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
