import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskify/SRC/COMMON/MODEL/Member.dart';
import 'package:taskify/SRC/COMMON/SERVICES/department.dart';
import 'package:taskify/SRC/COMMON/SERVICES/task.dart';
import 'package:taskify/THEME/theme.dart';

class HomeView extends StatefulWidget {
  final UserModel userModel;

  const HomeView({super.key, required this.userModel});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<String?> _departmentName;
  final TaskService _taskService = TaskService();

  int activeCount = 0;
  int lateCount = 0;
  int underApprovalCount = 0;
  int rejectedCount = 0;
  int completedCount = 0;

  @override
  void initState() {
    super.initState();
    _departmentName = _fetchDepartmentName();
    _initializeTaskCounts();
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

  Future<String?> _fetchDepartmentName() async {
    final departmentService = DepartmentService();
    return await departmentService
        .getDepartmentNameById(widget.userModel.departmentId);
  }

  @override
  Widget build(BuildContext context) {
    DateTime creationDate;
    if (widget.userModel.createdAt is String) {
      creationDate = DateTime.parse(widget.userModel.createdAt as String);
    } else {
      creationDate = widget.userModel.createdAt;
    }

    String formattedDate = DateFormat('MMM d, yyyy').format(creationDate);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: customDarkGrey,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi, ${widget.userModel.name}",
              style: const TextStyle(fontSize: 18),
            ),
            const Text(
              "Welcome back",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String?>(
              future: _departmentName,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator(color: customAqua);
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Text('Department not found');
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: customLightGrey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Department: ${snapshot.data}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Email: ${widget.userModel.email}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Account creation date: $formattedDate',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Your Tasks Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTaskInfoCard(
                    'Active',
                    activeCount,
                    Icons.check_circle,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTaskInfoCard(
                    'Late',
                    lateCount,
                    Icons.warning,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTaskInfoCard(
                    'Under Approval',
                    underApprovalCount,
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTaskInfoCard(
                    'Rejected',
                    rejectedCount,
                    Icons.cancel,
                    Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTaskInfoCard(
              'Completed',
              completedCount,
              Icons.done_all,
              Colors.green,
              width: double.infinity
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInfoCard(String label, int count, IconData icon, Color color, {double? width}) {
    return Card(
      color: customLightGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: width, // Apply the optional width here
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
