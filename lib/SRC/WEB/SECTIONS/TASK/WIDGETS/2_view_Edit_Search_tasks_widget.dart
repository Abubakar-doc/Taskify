import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/SERVICES/task.dart';
import 'package:taskify/SRC/WEB/UTILS/web_utils.dart';
import 'package:taskify/SRC/WEB/WIDGETS/small_widgets.dart';
import 'package:taskify/SRC/WEB/WIDGETS/task_table_list_item.dart';
import 'package:taskify/THEME/theme.dart';
import 'package:taskify/SRC/WEB/MODEL/task.dart';

class ViewEditSearchTasksWidget extends StatefulWidget {
  const ViewEditSearchTasksWidget({super.key});

  @override
  _ViewEditSearchTasksWidgetState createState() => _ViewEditSearchTasksWidgetState();
}

class _ViewEditSearchTasksWidgetState extends State<ViewEditSearchTasksWidget> {
  final TaskService _taskService = TaskService();
  List<Task> tasks = [];
  List<Task> filteredTasks = [];
  bool showAllTasks = false;
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      filterTasks(searchController.text);
    });
    _loadTasks();
  }

  void _loadTasks() {
    _taskService.getTasksStream().listen((tasksList) {
      setState(() {
        tasks = tasksList;
        filteredTasks = List.from(tasks);
        isLoading = false;
      });
    });
  }

  void filterTasks(String query) {
    final lowercaseQuery = query.toLowerCase();
    setState(() {
      filteredTasks = tasks.where((task) {
        return task.title.toLowerCase().contains(lowercaseQuery) ||
            (task.description?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
      showAllTasks = false;
    });
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
                    controller: searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: customLightGrey,
                      hintText: 'Search tasks...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    style: const TextStyle(color: Colors.white),
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
                  _buildTableHeader(),
                  if (isLoading)
                    LoadingPlaceholder()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: showAllTasks
                          ? filteredTasks.length
                          : (filteredTasks.length > 5 ? 5 : filteredTasks.length),
                      itemBuilder: (context, index) {
                        return TaskListItem(
                          name: filteredTasks[index].title,
                          description: filteredTasks[index].description ?? '',
                          onEdit: () {
                            _editTask(filteredTasks[index]);
                          },
                          onDelete: () {
                            _deleteTask(filteredTasks[index].id);
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

  void _editTask(Task task) {
    TextEditingController nameController = TextEditingController(text: task.title);
    TextEditingController descriptionController = TextEditingController(text: task.description ?? '');
    bool isNameEmpty = false;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Edit Task'),
              backgroundColor: customLightGrey,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'New Task Name',
                      border: const OutlineInputBorder(),
                      errorText: isNameEmpty ? 'Task name cannot be empty' : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        isNameEmpty = value.trim().isEmpty;
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
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: customAqua),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (nameController.text.trim().isEmpty) {
                      setState(() {
                        isNameEmpty = true;
                      });
                    } else {
                      setState(() {
                        isLoading = true; // Start loading
                      });

                      try {
                        Task updatedTask = Task(
                          id: task.id,
                          title: nameController.text,
                          description: descriptionController.text,
                          createdAt: task.createdAt ?? Timestamp.now(), // Handle null case
                          updatedAt: Timestamp.now(), // Update to current time
                        );

                        await _taskService.updateTask(updatedTask);

                        WebUtils().SuccessSnackBar(
                          context,
                          "Task has been successfully updated!",
                        );
                      } catch (e) {
                        WebUtils().ErrorSnackBar(
                          context,
                          'Failed to update task: $e',
                        );
                      } finally {
                        setState(() {
                          isLoading = false; // End loading
                        });
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customAqua,
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Save',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteTask(String taskId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false; // State variable for loading
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Delete Task'),
              backgroundColor: customLightGrey,
              content: const Text('Are you sure you want to delete this task?'),
              actions: <Widget>[
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: customAqua),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    setState(() {
                      isLoading = true; // Start loading
                    });
                    try {
                      await _taskService.deleteTask(taskId);
                      Navigator.of(context).pop();
                      WebUtils().InfoSnackBar(
                        context,
                        "Task has been successfully deleted!",
                      );
                    } catch (e) {
                      WebUtils().ErrorSnackBar(
                        context,
                        "Failed to delete task. Please try again.",
                      );
                    } finally {
                      setState(() {
                        isLoading = false; // End loading
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

}
