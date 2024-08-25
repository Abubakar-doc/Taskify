import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:taskify/SRC/COMMON/MODEL/Member.dart';
import 'package:taskify/SRC/COMMON/SERVICES/member.dart';
import 'package:taskify/SRC/COMMON/SERVICES/task.dart';
import 'package:taskify/SRC/COMMON/UTILS/Utils.dart';
import 'package:taskify/SRC/WEB/WIDGETS/small_widgets.dart';
import 'package:taskify/THEME/theme.dart';

class EvaluateTasksWidget extends StatefulWidget {
  const EvaluateTasksWidget({super.key});

  @override
  _EvaluateTasksWidgetState createState() => _EvaluateTasksWidgetState();
}

class _EvaluateTasksWidgetState extends State<EvaluateTasksWidget> {
  List<Map<String, dynamic>> filteredTasks = [];
  bool showAllTasks = false;
  TextEditingController searchController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> tasks = [];
  bool isLoadingMembers = true;
  bool isLoadingTasks = true;
  List<UserModel> memberList = [];
  final MemberService _memberService = MemberService();
  final TaskService _taskService = TaskService();
  Map<String, String> taskNamesMap = {};
  late StreamSubscription<Map<String, Map<String, dynamic>>> _tasksSubscription;

  @override
  void initState() {
    super.initState();

    _tasksSubscription =
        _taskService.getAllUnderApprovalAssignedTasksWithUserNames().listen(
      (tasks) async {
        final taskIds = tasks.keys.toList();
        _taskService.getTaskNameDescriptionByIds(taskIds).listen((taskNames) {
          setState(() {
            this.tasks = tasks.entries.map((e) {
              final taskId = e.key;
              final taskData = taskNames[taskId] ?? {};
              final taskDetails = e.value['taskDetails'] ?? {};
              final userResponses =
                  taskDetails['responses'] as List<dynamic>? ?? [];
              final dateAssigned = taskDetails['dateAssigned'];

              final latestUserResponse = userResponses.isNotEmpty
                  ? userResponses
                          .where((response) => response['role'] == 'user')
                          .last['response'] ??
                      'N/A'
                  : 'N/A';

              return {
                'taskId': taskId,
                'taskDetails': {
                  'name': taskData['title'] ?? 'N/A',
                  'description': taskData['description'] ?? 'No description',
                  'deadline': taskDetails['deadline'] ?? 'N/A',
                  'response': latestUserResponse,
                  'responses': userResponses,
                  'dateAssigned': dateAssigned,
                },
                'userName': e.value['userName'],
                'userId': e.value['documentId'],
              };
            }).toList();

            filteredTasks = this.tasks;
            isLoadingTasks = false;
          });
        }, onError: (error) {
          print('Error fetching task names: $error');
        });
      },
      onError: (error) {
        print('Error fetching tasks: $error');
      },
    );

    _memberService.getApprovedMembersHavingDepartmentForTask().listen(
        (members) {
      setState(() {
        memberList = members;
        isLoadingMembers = false;
      });
    }, onError: (error) {
      print('Error fetching members: $error');
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
                  _buildTableHeader(),
                  isLoadingTasks
                      ? const LoadingPlaceholder()
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: showAllTasks
                              ? filteredTasks.length
                              : (filteredTasks.length > 5
                                  ? 5
                                  : filteredTasks.length),
                          itemBuilder: (context, index) {
                            return TaskTableListItem(
                              taskId: filteredTasks[index]
                                  ['taskId'], // Pass taskId
                              taskName: filteredTasks[index]['taskDetails']
                                      ?['name'] ??
                                  'N/A',
                              deadline: filteredTasks[index]['taskDetails']
                                      ?['deadline'] ??
                                  'N/A',
                              memberName:
                                  filteredTasks[index]['userName'] ?? 'N/A',
                              response: filteredTasks[index]['taskDetails']
                                      ?['response'] ??
                                  'N/A',
                              onReject: () {
                                _confirmAction(index, 'Reject');
                              },
                              onPass: () {
                                _confirmAction(index, 'Pass');
                              },
                              description: filteredTasks[index]['taskDetails']
                                      ['description'] ??
                                  'N/A',
                              userResponses: filteredTasks[index]['taskDetails']
                                      ['responses'] ??
                                  [],
                              dateAssigned: filteredTasks[index]['taskDetails']
                                  ?['dateAssigned'],
                            );
                          }),
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
        final taskName = task['taskDetails']?['name'] ?? '';
        final userName = task['userName'] ?? '';
        final deadline = task['taskDetails']?['deadline'] ?? '';
        final response = task['taskDetails']?['response'] ?? '';
        return taskName.toLowerCase().contains(query) ||
            userName.toLowerCase().contains(query) ||
            deadline.toLowerCase().contains(query) ||
            response.toLowerCase().contains(query);
      }).toList();
      showAllTasks = false;
    });
  }

  void _confirmAction(int index, String action) {
    final taskId = filteredTasks[index]['taskId'];
    final memberId = filteredTasks[index]['userId'];

    final TextEditingController messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Variable to track loading state
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                        labelText: action == 'Reject'
                            ? 'Enter your message (Required)'
                            : 'Enter your message (Optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      validator: (value) {
                        if (action == 'Reject' &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Message is required for rejection';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
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
                    style:
                        TextStyle(color: customAqua), // Match your theme color
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() ?? false) {
                            setState(() {
                              isLoading = true;
                            });
                            try {
                              if (action == 'Pass') {
                                await _taskService.passTask(
                                    memberId, taskId, messageController.text);
                                Utils().SuccessSnackBar(context,
                                    "Task marked as completed successfully!");
                              } else if (action == 'Reject') {
                                await _taskService.rejectTask(
                                    memberId, taskId, messageController.text);
                                Utils().InfoSnackBar(context, "Task rejected!");
                              }

                              // Update UI after action
                              setState(() {
                                filteredTasks.removeAt(index);
                              });
                            } catch (error) {
                              print('Error updating task status: $error');
                              // Utils().ErrorSnackBar(
                              //     context, "Failed to update task status.");
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.of(context).pop();
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        action == 'Reject' ? Colors.red.shade400 : customAqua,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2.0,
                          ),
                        )
                      : Text(
                          action,
                          style: TextStyle(
                            color: action == 'Reject'
                                ? Colors.white
                                : Colors.black,
                          ),
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

class TaskTableListItem extends StatelessWidget {
  final String taskId;
  final String taskName;
  final String description;
  final userResponses;
  final String deadline;
  final String memberName;
  final String response;
  final void Function() onReject;
  final void Function() onPass;
  final Timestamp dateAssigned;

  const TaskTableListItem({
    super.key,
    required this.taskId, // Add taskId
    required this.taskName,
    required this.description,
    required this.deadline,
    required this.memberName,
    required this.response,
    required this.onReject,
    required this.onPass,
    required this.userResponses,
    required this.dateAssigned,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              _buildCell(
                  taskName, const TextStyle(color: Colors.white, fontSize: 18)),
              _buildCell(
                deadline,
                TextStyle(
                  color:
                      _isDeadlineRed(DateTime.parse(deadline), DateTime.now())
                          ? Colors.red.shade400
                          : Colors.white,
                  fontSize: 18,
                ),
              ),
              _buildCell(memberName,
                  const TextStyle(color: Colors.white, fontSize: 18)),
              _chatCell(response, context),
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

  Widget _buildCell(String text, TextStyle textStyle) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          text,
          style: textStyle,
        ),
      ),
    );
  }

  bool _isDeadlineRed(DateTime deadline, DateTime now) {
    // Reset time to compare only dates
    DateTime deadlineDate =
        DateTime(deadline.year, deadline.month, deadline.day);
    DateTime nowDate = DateTime(now.year, now.month, now.day);

    return deadlineDate.isBefore(nowDate);
  }

  Widget _chatCell(String text, BuildContext context) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis, // Handle overflow
              ),
            ),
            ElevatedButton(
              onPressed: () => _showChatDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Icon(
                Icons.message_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final DateTime now = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final dialogWidth = screenWidth * 0.8;
        final dialogHeight = screenHeight * 0.6;
        final columnHeight = dialogHeight / 3;

        bool isDeadlineRed(DateTime deadline, DateTime now) {
          DateTime deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);
          DateTime nowDate = DateTime(now.year, now.month, now.day);

          return deadlineDate.isBefore(nowDate);
        }

        return AlertDialog(
          backgroundColor: customLightGrey,
          title: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Chat - ',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                TextSpan(
                  text: taskName,
                  style: const TextStyle(fontSize: 24, color: customAqua),
                ),
              ],
            ),
          ),
          content: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: columnHeight,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Task Description: ',
                                  style: TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                                TextSpan(
                                  text: description,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Assigned to: ',
                                  style: TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                                TextSpan(
                                  text: memberName,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Date Assigned: ',
                                  style: TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                                TextSpan(
                                  text: DateFormat.yMMMd().format(dateAssigned.toDate()),
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Deadline: ',
                                  style: TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                                TextSpan(
                                  text: DateFormat.yMMMd().format(DateTime.parse(deadline)),
                                  style: TextStyle(
                                    color: isDeadlineRed(DateTime.parse(deadline), DateTime.now())
                                        ? Colors.red.shade400
                                        : Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  const Divider(color: Colors.white70),
                  const SizedBox(height: 10,),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          color: Color(0xFF2A3038),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildChatMessages(dialogWidth),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close', style: TextStyle(color: customAqua)),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildChatMessages(double dialogWidth) {
    final List<Widget> chatMessages = [];
    DateTime? previousDate;

    for (var response in userResponses) {
      final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
          response['timestamp'].seconds * 1000);
      final String formattedDate = _formatChatDate(timestamp);
      final String role = response['role'] ?? 'Unknown';
      final String text = response['response'] ?? '';

      if (previousDate == null || !_isSameDate(previousDate, timestamp)) {
        chatMessages.add(
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                formattedDate,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ),
        );
      }

      chatMessages.add(
        Align(
          alignment:
              role == 'user' ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: dialogWidth * 0.6),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: const Color(0xFF444951),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${role == 'admin' ? role : memberName} ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: '(${DateFormat('h:mm a').format(timestamp)})',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );

      previousDate = timestamp;
    }

    return chatMessages;
  }

  String _formatChatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime yesterday = now.subtract(const Duration(days: 1));

    if (_isSameDate(date, now)) {
      return 'Today';
    } else if (_isSameDate(date, yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('dd-MM-yyyy').format(date);
    }
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
