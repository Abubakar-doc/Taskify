import 'package:flutter/material.dart';
import 'package:taskify/THEME/theme.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';

class AssignTasksToMembersWidget extends StatefulWidget {
  const AssignTasksToMembersWidget({super.key});

  @override
  _AssignTasksToMembersWidgetState createState() => _AssignTasksToMembersWidgetState();
}

class _AssignTasksToMembersWidgetState extends State<AssignTasksToMembersWidget> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _memberController = TextEditingController();
  final TextEditingController _memberEmailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Test data
  List<Map<String, String>> tasks = [
    {'name': 'Task 1', 'description': 'Description for Task 1'},
    {'name': 'Task 2', 'description': 'Description for Task 2'},
    {'name': 'Task 3', 'description': 'Description for Task 3'},
    {'name': 'Task 4', 'description': 'Description for Task 4'},
    {'name': 'Task 5', 'description': 'Description for Task 5'},
    {'name': 'Task 6', 'description': 'Description for Task 6'},
    {'name': 'Task 7', 'description': 'Description for Task 7'},
    {'name': 'Task 8', 'description': 'Description for Task 8'},
    {'name': 'Task 9', 'description': 'Description for Task 9'},
    {'name': 'Task 10', 'description': 'Description for Task 10'}
  ];
  List<Map<String, String>> memberList = [
    {'name': 'John Doe', 'email': 'john.doe@example.com'},
    {'name': 'Jane Smith', 'email': 'jane.smith@example.com'},
    {'name': 'ada Johnson', 'email': 'mike.johnson@example.com'},
    {'name': 'bhalu Johnson', 'email': 'mike.johnson@example.com'},
  ];

  Map<String, String> selectedTask = {};
  Map<String, String> selectedMember = {};

  @override
  void dispose() {
    _taskController.dispose();
    _memberController.dispose();
    _memberEmailController.dispose();
    super.dispose();
  }

  void handleCancel() {
    setState(() {
      _taskController.clear();
      _memberController.clear();
      _memberEmailController.clear();
      selectedTask = {};
      selectedMember = {};
    });
  }

  List<Map<String, String>> getTaskSuggestions(String query) {
    return tasks
        .where((task) => task['name']!.toLowerCase().contains(query.toLowerCase()))
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
                return getTaskSuggestions(pattern)
                    .map((task) => task['name']!)
                    .toList();
              },
              itemBuilder: (context, String suggestion) {
                final task = tasks.firstWhere((task) => task['name'] == suggestion);
                return ListTile(
                  title: Text(suggestion),
                  subtitle: Text(task['description']!),
                );
              },
              itemSeparatorBuilder: (context, index) {
                return const Divider();
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (String suggestion) {
                final task = tasks.firstWhere((task) => task['name'] == suggestion);
                setState(() {
                  selectedTask = task;
                  _taskController.text = suggestion;
                });
              },
              displayAllSuggestionWhenTap: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a Task';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: selectedTask['description']),
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
                  _memberController.text = suggestion;
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
                              // Implement Add Member logic here
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
