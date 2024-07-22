import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/UTILS/web_utils.dart';
import 'package:taskify/THEME/theme.dart';

class EvaluateTasksWidget extends StatefulWidget {
  const EvaluateTasksWidget({super.key});

  @override
  _EvaluateTasksWidgetState createState() => _EvaluateTasksWidgetState();
}

class _EvaluateTasksWidgetState extends State<EvaluateTasksWidget> {
  List<Map<String, String>> tasks = [
    {'taskName': 'Task 1', 'memberName': 'John', 'deadline': '2023-12-01', 'response': 'I have completed the task'},
    {'taskName': 'Task 2', 'memberName': 'Jane', 'deadline': '2023-12-05', 'response': 'I have completed the task'},
    {'taskName': 'Task 3', 'memberName': 'Mike', 'deadline': '2023-12-10', 'response': 'I have completed the task'},
    {'taskName': 'Task 4', 'memberName': 'Alice', 'deadline': '2023-12-15', 'response': 'I have completed the task'},
    {'taskName': 'Task 5', 'memberName': 'Bob', 'deadline': '2023-12-20', 'response': 'I have completed the task'},
    {'taskName': 'Task 6', 'memberName': 'Asad', 'deadline': '2023-12-10', 'response': 'I have completed the task'},
    {'taskName': 'Task 7', 'memberName': 'Khabib', 'deadline': '2023-12-12', 'response': 'I have completed the task'},
    // Add more tasks as needed
  ];
  List<Map<String, String>> filteredTasks = [];
  bool showAllTasks = false;

  TextEditingController searchController = TextEditingController();
  TextEditingController messageController = TextEditingController(); // New controller

  @override
  void initState() {
    super.initState();
    filteredTasks.addAll(tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Evaluate Tasks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: customLightGrey,
                      hintText: 'Search tasks...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      filterTasks(value);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    filterTasks(searchController.text);
                  },
                  icon: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: customLightGrey,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  _buildTableHeader(), // Table Header with titles
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: showAllTasks
                        ? filteredTasks.length
                        : (filteredTasks.length > 5 ? 5 : filteredTasks.length),
                    itemBuilder: (context, index) {
                      return TaskTableListItem(
                        taskName: filteredTasks[index]['taskName']!,
                        deadline: filteredTasks[index]['deadline']!,
                        memberName: filteredTasks[index]['memberName']!,
                        response: filteredTasks[index]['response']!,
                        onReject: () {
                          _confirmAction(index, 'Reject');
                        },
                        onPass: () {
                          _confirmAction(index, 'Pass');
                        },
                      );
                    },
                  ),
                  if (filteredTasks.length > 5 && !showAllTasks)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showAllTasks = true;
                        });
                      },
                      child: Text(
                        'Show More (${filteredTasks.length - 5} more)',
                        style: const TextStyle(
                          color: customAqua,
                        ),
                      ),
                    ),
                  if (showAllTasks && filteredTasks.length > 5)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showAllTasks = false;
                        });
                      },
                      child: const Text(
                        'Show Less',
                        style: TextStyle(
                          color: customAqua,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Task Name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Deadline',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Member Name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Member Response',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Actions',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void filterTasks(String query) {
    query = query.toLowerCase();
    setState(() {
      filteredTasks = tasks.where((task) {
        return task['taskName']!.toLowerCase().contains(query) || task['memberName']!.toLowerCase().contains(query) || task['deadline']!.toLowerCase().contains(query) || task['response']!.toLowerCase().contains(query);
      }).toList();
      // Reset showAllTasks when filtering
      showAllTasks = false;
    });
  }

  void _confirmAction(int index, String action) {
    // Create a TextEditingController for the message TextField
    final TextEditingController messageController = TextEditingController();
    // Create a global key for the form
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$action Task'),
          backgroundColor: customLightGrey,
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Are you sure you want to $action this task?'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: messageController,
                  decoration: InputDecoration(
                    labelText: 'Enter your message (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  // validator: (value) {
                  //   if (value == null || value.trim().isEmpty) {
                  //     return 'Message cannot be empty';
                  //   }
                  //   return null;
                  // },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: customAqua), // Match your theme color
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  setState(() {
                    filteredTasks.removeAt(index);
                    if (action == 'Pass') {
                      WebUtils().showSuccessToast("Task marked as completed successfully!", context);
                    } else {
                      WebUtils().showErrorToast("Task rejected!", context);
                    }
                  });
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: action == 'Reject' ? Colors.red.shade400 : customAqua,
              ),
              child: Text(
                action,
                style: TextStyle(
                  color: action == 'Reject' ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}

class TaskTableListItem extends StatelessWidget {
  final String taskName;
  final String deadline;
  final String memberName;
  final String response;
  final VoidCallback onReject;
  final VoidCallback onPass;

  const TaskTableListItem({super.key, 
    required this.taskName,
    required this.deadline,
    required this.memberName,
    required this.response,
    required this.onReject,
    required this.onPass,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              _buildCell(taskName),
              _buildCell(deadline),
              _buildCell(memberName),
              _buildCell(response),
              _buildActionsCell(),
            ],
          ),
          const Divider(
            height: 1,
            color: Color(0xBB949494),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(String text) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildActionsCell() {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: onPass,
              style: ElevatedButton.styleFrom(
                backgroundColor: customAqua,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                'Pass',
                style: TextStyle(
                  color: customDarkGrey,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onReject,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                'Reject',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
