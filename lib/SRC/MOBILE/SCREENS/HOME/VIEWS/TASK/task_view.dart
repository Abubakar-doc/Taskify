import 'package:flutter/material.dart';
import 'package:taskify/SRC/COMMON/MODEL/Member.dart';
import 'package:taskify/SRC/COMMON/SERVICES/task.dart';
import 'package:taskify/SRC/MOBILE/SCREENS/HOME/VIEWS/TASK/task_submit_and_detail.dart';
import 'package:taskify/THEME/theme.dart';

class TaskView extends StatefulWidget {
  final UserModel userModel;

  const TaskView({super.key, required this.userModel});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView>
    with SingleTickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  late TabController _tabController;
  int activeCount = 0;
  int lateCount = 0;
  int underApprovalCount = 0;
  int completedCount = 0;
  int rejectedCount = 0;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeTaskCounts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeTaskCounts() {
    // Using the updateTaskCounts method from TaskService
    _taskService.updateTaskCounts(widget.userModel.uid, (taskCounts) {
      setState(() {
        activeCount = taskCounts.activeCount;
        lateCount = taskCounts.lateCount;
        underApprovalCount = taskCounts.underApprovalCount;
        rejectedCount = taskCounts.rejectedCount;
        completedCount = taskCounts.completedCount;
      });
    });
  }

  Stream<Map<String, dynamic>> _getFilteredTasksStream(String filter) {
    return _taskService
        .getTasksStreamForMember(widget.userModel.uid)
        .map((tasks) {
      final now = DateTime.now();
      final filteredTasks = <String, dynamic>{};

      for (var entry in tasks.entries) {
        final taskDetails = entry.value;
        final deadline = DateTime.parse(taskDetails['deadline']);
        final status = taskDetails['status'];

        if (_isSearching) {
          final searchQueryLower = _searchQuery.toLowerCase();
          final title = taskDetails['title'].toString().toLowerCase();
          final description =
          taskDetails['description'].toString().toLowerCase();
          final deadlineString =
          taskDetails['deadline'].toString().toLowerCase();

          if (title.contains(searchQueryLower) ||
              description.contains(searchQueryLower) ||
              deadlineString.contains(searchQueryLower)) {
            filteredTasks[entry.key] = taskDetails;
          }
        } else {
          if (filter == 'Active' &&
              ((deadline.isAfter(now) && status == 'pending') ||
                  status == 'Rejected' ||
                  (deadline.isBefore(now) && status == 'pending'))) {
            // Include pending, rejected, and late tasks in the Active filter
            filteredTasks[entry.key] = taskDetails;
          } else if (filter == 'Late' &&
              (deadline.isBefore(now) &&
                  (status == 'pending' || status == 'Rejected'))) {
            filteredTasks[entry.key] = taskDetails;
          } else if (filter == 'Under Approval' && status == 'Under Approval') {
            filteredTasks[entry.key] = taskDetails;
          } else if (filter == 'Rejected' && status == 'Rejected') {
            filteredTasks[entry.key] = taskDetails;
          } else if (filter == 'Completed' && status == 'Completed') {
            filteredTasks[entry.key] = taskDetails;
          } else if (filter == 'All') {
            filteredTasks[entry.key] = taskDetails;
          }
        }
      }

      return filteredTasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: customDarkGrey,
        title: _isSearching
            ? _buildSearchField()
            : const Text(
                'Manage Tasks',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: customAqua,
                ),
              ),
        actions: _buildActions(),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: customAqua,
          labelColor: customAqua,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: [
            Tab(
              child: Text(
                'Active ($activeCount)',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Tab(
              child: Text(
                'Late ($lateCount)',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Tab(
              child: Text(
                'Rejected ($rejectedCount)',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Tab(
              child: Text(
                'Under Approval ($underApprovalCount)',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Tab(
              child: Text(
                'Completed ($completedCount)',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList('Active'),
          _buildTaskList('Late'),
          _buildTaskList('Rejected'),
          _buildTaskList('Under Approval'),
          _buildTaskList('Completed'),
        ],
      ),
    );
  }

  Widget _buildTaskList(String filter) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _getFilteredTasksStream(filter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            color: customAqua,
          ));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final tasks = snapshot.data ?? {};
        if (tasks.isEmpty) {
          return const Center(
            child: Text(
              'No tasks found.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(18.0),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final taskId = tasks.keys.elementAt(index);
            final taskDetails = tasks[taskId]!;
            final deadline = DateTime.parse(taskDetails['deadline']);
            DateTime deadlineDate =
                DateTime(deadline.year, deadline.month, deadline.day);
            DateTime nowDate = DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day);
            final isMissed = deadlineDate.isBefore(nowDate);

            // Set status color based on task status
            Color statusColor;
            if (taskDetails['status'] == 'Rejected') {
              statusColor = Colors.red;
            } else if (taskDetails['status'] == 'Completed') {
              statusColor = Colors.green;
            } else {
              statusColor = Colors.white;
            }

            return Card(
              color: customLightGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(bottom: 16.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(
                        taskId: taskId,
                        memberId: widget.userModel.uid,
                        title: taskDetails['title'],
                        description: taskDetails['description'],
                        deadline: taskDetails['deadline'],
                        status: taskDetails['status'],
                        dateAssigned: taskDetails['dateAssigned'],
                        dateCompleted: taskDetails['dateCompleted'],
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskDetails['title'],
                        style: const TextStyle(
                          color: customAqua,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Deadline: ',
                            ),
                            TextSpan(
                              text: taskDetails['deadline'],
                              style: TextStyle(
                                color: filter == 'Under Approval'
                                    ? Colors.white70
                                    : (isMissed &&
                                            taskDetails['status'] != 'Completed'
                                        ? Colors.red.shade600
                                        : Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Status: ',
                            ),
                            TextSpan(
                              text: taskDetails['status'],
                              style: TextStyle(
                                  color: statusColor), // Apply the status color
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: customAqua,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskDetailScreen(
                                  taskId: taskId,
                                  memberId: widget.userModel.uid,
                                  title: taskDetails['title'],
                                  description: taskDetails['description'],
                                  deadline: taskDetails['deadline'],
                                  status: taskDetails['status'],
                                  dateAssigned: taskDetails['dateAssigned'],
                                  dateCompleted: taskDetails['dateCompleted'],
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'View',
                            style: TextStyle(
                              color: customDarkGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 18.0),
      onChanged: (query) {
        setState(() {
          _searchQuery = query;
        });
      },
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
            });
          },
        ),
      ];
    }

    return [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          setState(() {
            _isSearching = true;
          });
        },
      ),
    ];
  }
}
