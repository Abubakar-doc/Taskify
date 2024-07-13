import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/WIDGETS/task_table_list_item.dart';
import 'package:taskify/THEME/theme.dart';

class ViewEditSearchTasksWidget extends StatefulWidget {
  const ViewEditSearchTasksWidget({super.key});

  @override
  _ViewEditSearchTasksWidgetState createState() => _ViewEditSearchTasksWidgetState();
}

class _ViewEditSearchTasksWidgetState extends State<ViewEditSearchTasksWidget> {
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
  List<Map<String, String>> filteredTasks = [];
  bool showAllTasks = false;

  TextEditingController searchController = TextEditingController();

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
                  'Tasks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex: 1,
                  child: TextField(
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
                    // Optional: Implement search logic here
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
                      return TaskListItem(
                        name: filteredTasks[index]['name']!,
                        description: filteredTasks[index]['description']!,
                        onEdit: () {
                          _editTask(index);
                        },
                        onDelete: () {
                          _deleteTask(filteredTasks[index]['name']!);
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
              'Name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Description',
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
        return task['name']!.toLowerCase().contains(query) || task['description']!.toLowerCase().contains(query);
      }).toList();
      // Reset showAllTasks when filtering
      showAllTasks = false;
    });
  }

  void _editTask(int index) {
    TextEditingController nameController = TextEditingController(text: filteredTasks[index]['name']);
    TextEditingController descriptionController = TextEditingController(text: filteredTasks[index]['description']);
    bool _isNameEmpty = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          backgroundColor: customLightGrey,
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'New Task Name',
                      border: const OutlineInputBorder(),
                      errorText: _isNameEmpty ? 'Task name cannot be empty' : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isNameEmpty = value.trim().isEmpty;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'New Task Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              );
            },
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
                if (nameController.text.trim().isEmpty) {
                  setState(() {
                    _isNameEmpty = true;
                  });
                } else {
                  setState(() {
                    tasks[index]['name'] = nameController.text;
                    tasks[index]['description'] = descriptionController.text;
                    filteredTasks[index]['name'] = nameController.text;
                    filteredTasks[index]['description'] = descriptionController.text;
                  });
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: customAqua, // Match your theme color
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }


  void _deleteTask(String taskName) {
    // Placeholder function for deleting task
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          backgroundColor: customLightGrey,
          content: Text('Are you sure you want to delete $taskName?'),
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
                // Implement delete logic here
                setState(() {
                  tasks.removeWhere((task) => task['name'] == taskName);
                  filteredTasks.removeWhere((task) => task['name'] == taskName);
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400, // Use your delete button color
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
