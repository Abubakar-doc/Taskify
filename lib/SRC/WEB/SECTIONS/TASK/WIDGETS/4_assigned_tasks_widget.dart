import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskify/SRC/COMMON/MODEL/Member.dart';
import 'package:taskify/SRC/COMMON/UTILS/Utils.dart';
import 'package:taskify/SRC/COMMON/SERVICES/member.dart';
import 'package:taskify/SRC/COMMON/SERVICES/task.dart';
import 'package:taskify/SRC/WEB/WIDGETS/small_widgets.dart';
import 'package:taskify/THEME/theme.dart';

class AssignedTasksWidget extends StatefulWidget {
  const AssignedTasksWidget({super.key});

  @override
  _AssignedTasksWidgetState createState() => _AssignedTasksWidgetState();
}

class _AssignedTasksWidgetState extends State<AssignedTasksWidget> {
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> filteredTasks = [];
  bool showAllTasks = false;
  TextEditingController searchController = TextEditingController();
  TextEditingController messageController = TextEditingController();
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
        _taskService.getAllPendingAssignedTasksWithUserNames().listen(
      (tasks) async {
        final taskIds = tasks.keys.toList();
        _taskService.getTaskNamesByIds(taskIds).listen((taskNames) {
          setState(() {
            this.tasks = tasks.entries
                .map((e) => {
                      'taskId': e.key,
                      'taskDetails': e.value['taskDetails'],
                      'userName': e.value['userName'],
                      'userId': e.value['documentId'],
                    })
                .toList();
            filteredTasks = this.tasks;
            taskNamesMap = taskNames;
            isLoadingTasks = false;
          });
        });
      },
      onError: (error) {
        print('Error: $error');
        // Handle error
      },
    );

    _memberService
        .getApprovedMembersHavingDepartmentForTask()
        .listen((members) {
      setState(() {
        memberList = members;
        isLoadingMembers = false;
      });
    });
  }

  @override
  void dispose() {
    _tasksSubscription.cancel();
    super.dispose();
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
                  'Assigned Tasks',
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
                      filterTasks(value, taskNamesMap);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    filterTasks(searchController.text, taskNamesMap);
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
                            final taskName =
                                taskNamesMap[filteredTasks[index]['taskId']] ??
                                    'Unnamed Task';
                            return TaskTableListItem(
                              taskName: taskName,
                              deadline: filteredTasks[index]['taskDetails']
                                      ['deadline'] ??
                                  'No Deadline',
                              memberName:
                                  filteredTasks[index]['userName'] ?? 'Unknown',
                              onChangeDeadline: () {
                                _changeDeadlineAction(index);
                              },
                              onReassignTask: () {
                                _reassignTaskAction(index);
                              },
                              onViewHistory: () {
                                _showTaskHistoryDialog(index);
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

  void filterTasks(String query, Map<String, String> taskNamesMap) {
    query = query.toLowerCase();
    setState(() {
      filteredTasks = tasks.where((task) {
        final taskName = taskNamesMap[task['taskId']]?.toLowerCase() ?? '';
        return taskName.contains(query) ||
            task['userName']!.toLowerCase().contains(query) ||
            task['taskDetails']['deadline']!.toLowerCase().contains(query);
      }).toList();
      // Reset showAllTasks when filtering
      showAllTasks = false;
    });
  }

  void _showTaskHistoryDialog(int index) {
    final taskId = filteredTasks[index]['taskId'];
    final taskName = taskNamesMap[taskId] ?? 'Unnamed Task';

    // Show a loading dialog while fetching data
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: customLightGrey,
          title: const Text('Loading'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Colors.grey,
              ),
              const SizedBox(width: 16.0),
              Text('Fetching $taskName history...'),
            ],
          ),
        );
      },
    );

    _taskService
        .getAssignedToByTaskIds([taskId])
        .first
        .then((assignedToMap) async {
          final assignedToList = assignedToMap[taskId] ?? [];

          final memberIds =
              assignedToList.map((a) => a['memberId'] as String).toList();
          final memberDetails = await _memberService.getMembersByIds(memberIds);
          String formatTimestamp(Timestamp timestamp) {
            final date = timestamp.toDate();
            final formatter = DateFormat('MMM d, yyyy h:mm a');
            return formatter.format(date);
          }

          Navigator.of(context).pop();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: customLightGrey,
                title: Text('$taskName Assignment History'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (assignedToList.isNotEmpty) ...[
                        // Display the initial assignment header
                        const Text(
                          'First Assigned To:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...assignedToList
                            .asMap()
                            .entries
                            .where((entry) => entry.key == 0)
                            .map((entry) {
                          final assignment = entry.value;
                          final memberId = assignment['memberId'] as String;
                          final timestamp =
                              (assignment['timestamp'] as Timestamp);
                          final member = memberDetails[memberId];
                          final memberName = member?.name ?? 'Unknown';
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xff282d33),
                              borderRadius: BorderRadius.circular(
                                  8.0), // Adjust the radius as needed
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Match the radius with the decoration
                              child: ListTile(
                                title: Text(memberName),
                                subtitle: Text(
                                  'Assigned on: ${formatTimestamp(timestamp)}',
                                ),
                              ),
                            ),
                          );
                        }),

                        // Display the reassigned header if there are reassignments
                        if (assignedToList.length > 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Than Reassigned To:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ...assignedToList
                            .asMap()
                            .entries
                            .where((entry) => entry.key != 0)
                            .map((entry) {
                          final assignment = entry.value;
                          final memberId = assignment['memberId'] as String;
                          final timestamp =
                              (assignment['timestamp'] as Timestamp);
                          final member = memberDetails[memberId];
                          final memberName = member?.name ?? 'Unknown';

                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xff282d33),
                              borderRadius: BorderRadius.circular(
                                  8.0), // Adjust the radius as needed
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Match the radius with the decoration
                                  child: ListTile(
                                    title: Text(memberName),
                                    subtitle: Text(
                                      'Reassigned on: ${formatTimestamp(timestamp)}',
                                    ),
                                  ),
                                ),
                                if (entry.key == assignedToList.length - 1)
                                  const Positioned(
                                    top: 8.0,
                                    right: 8.0,
                                    child: Text(
                                      'Current',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close',
                        style: TextStyle(color: customAqua)),
                  ),
                ],
              );
            },
          );
        })
        .catchError((error) {
          Navigator.of(context).pop(); // Close the loading dialog

          // Handle error (e.g., show an error message)
          Utils().ErrorSnackBar(
            context,
            'Error fetching assignment history: $error',
          );
        });
  }

  void _changeDeadlineAction(int index) {
    final taskId = filteredTasks[index]['taskId'];
    final taskName = taskNamesMap[taskId] ?? 'Unnamed Task';
    final TextEditingController deadlineController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final memberId = filteredTasks[index]['userId'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            bool isLoading = false;

            Future<void> updateDeadline() async {
              if (formKey.currentState?.validate() ?? false) {
                setState(() {
                  isLoading = true;
                });

                try {
                  // Update the task deadline
                  await TaskService().updateTaskDeadline(
                    taskId,
                    memberId,
                    deadlineController.text,
                  );

                  Utils().SuccessSnackBar(
                      context, 'Deadline updated successfully!');
                } catch (e) {
                  Utils()
                      .ErrorSnackBar(context, 'Failed to update deadline: $e');
                } finally {
                  Navigator.of(context).pop();
                }
              }
            }

            return AlertDialog(
              backgroundColor: customLightGrey,
              title: Text('Adjust "$taskName" Deadline'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: deadlineController,
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xff282d33),
                    hintText: 'Select new date of deadline',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a deadline';
                    }
                    return null;
                  },
                  onTap: () {
                    _selectDate(context, deadlineController);
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child:
                      const Text('Cancel', style: TextStyle(color: customAqua)),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : updateDeadline,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customAqua,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Update',
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

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime currentDate = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && selectedDate != currentDate) {
      controller.text = "${selectedDate.toLocal()}"
          .split(' ')[0]; // Format the date as needed
    }
  }

  void _reassignTaskAction(int index) {
    final TextEditingController memberController = TextEditingController();
    final TextEditingController memberEmailController =
        TextEditingController();
    final formKey = GlobalKey<FormState>();
    final taskId = filteredTasks[index]['taskId'];
    final taskName = taskNamesMap[taskId] ?? 'Unnamed Task';
    final currentMemberId = filteredTasks[index]['userId'];
    final currentMember =
        memberList.firstWhere((member) => member.uid == currentMemberId);
    final currentMemberName = currentMember.name;
    String? newMemberId;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Reassign Task: $taskName'),
              backgroundColor: customLightGrey,
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                        'Please select another member to reassign the task.'),
                    const SizedBox(height: 8),
                    DropDownSearchFormField(
                      textFieldConfiguration: TextFieldConfiguration(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: customLightGrey,
                          hintText: 'Search Member',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Colors.white, // Border color
                              width: 1.0, // Border width
                            ),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12.0),
                        ),
                        controller: memberController,
                      ),
                      suggestionsCallback: (pattern) {
                        if (isLoadingMembers) {
                          return ['Loading...'];
                        } else if (memberList.isEmpty) {
                          return ['No members found'];
                        }
                        // Filter out the current member
                        return memberList
                            .where((member) =>
                                member.uid != currentMemberId &&
                                member.name
                                    .toLowerCase()
                                    .contains(pattern.toLowerCase()))
                            .map((member) => member.name)
                            .toList();
                      },
                      itemBuilder: (context, String suggestion) {
                        if (suggestion == 'Loading...') {
                          return const ListTile(title: Text('Loading...'));
                        } else if (suggestion == 'No members found') {
                          return const ListTile(
                              title: Text('No members found'));
                        } else {
                          final member = memberList.firstWhere(
                              (member) => member.name == suggestion);
                          return ListTile(
                            title: Text(suggestion),
                            subtitle: Text(member.email),
                          );
                        }
                      },
                      itemSeparatorBuilder: (context, index) {
                        return const Divider();
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      onSuggestionSelected: (String suggestion) {
                        if (suggestion != 'Loading...' &&
                            suggestion != 'No members found') {
                          final member = memberList.firstWhere(
                              (member) => member.name == suggestion);
                          setState(() {
                            memberController.text = member.name;
                            memberEmailController.text = member.email;
                            newMemberId =
                                member.uid; // Store the selected member ID
                          });
                        }
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
                      controller: memberEmailController,
                      enabled: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: customLightGrey,
                        hintText: 'Member Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.white, // Border color
                            width: 1.0, // Border width
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12.0),
                      ),
                      style: const TextStyle(color: Colors.white),
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
                            final newMemberName = memberController.text;
                            final deadline = filteredTasks[index]['taskDetails']
                                    ['deadline'] ??
                                'No Deadline';

                            setState(() {
                              isLoading = true;
                            });

                            try {
                              await _taskService.reallocateTask(
                                taskId,
                                newMemberId ?? '', // Pass the member ID
                                deadline,
                                currentMemberId,
                              );
                              Navigator.of(context).pop();
                              Utils().SuccessSnackBar(
                                context,
                                'Successfully reassigned the task "$taskName" from $currentMemberName to $newMemberName.',
                              );
                            } catch (e) {
                              Utils().ErrorSnackBar(
                                context,
                                'Error reassigning task "$taskName" from $currentMemberName to $newMemberName: $e',
                              );
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2.0,
                          ),
                        )
                      : const Text(
                          'Reassign',
                          style: TextStyle(
                            color: Colors.black,
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

Widget _buildTableHeader() {
  return const Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            'Task',
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
            'Assigned to',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
        Expanded(
          flex: 2, // New column for History
          child: Text(
            'History',
            textAlign: TextAlign.center, // Center-align the header text
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
        Expanded(
          flex: 4, // Match this flex value with the actions cell in the body
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Actions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class TaskTableListItem extends StatelessWidget {
  final String taskName;
  final String deadline;
  final String memberName;
  final VoidCallback onChangeDeadline;
  final VoidCallback onReassignTask;
  final VoidCallback onViewHistory; // New callback for history button

  const TaskTableListItem({
    super.key,
    required this.taskName,
    required this.deadline,
    required this.memberName,
    required this.onChangeDeadline,
    required this.onReassignTask,
    required this.onViewHistory, // Initialize this callback
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              _buildCell(taskName, flex: 3),
              _buildCell(deadline, flex: 3),
              _buildCell(memberName, flex: 3),
              _buildHistoryCell(),
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

  Widget _buildCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
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

  Widget _buildHistoryCell() {
    return Expanded(
      flex: 2, // Flex value for history column
      child: Center(
        // Center the icon within the cell
        child: IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
          onPressed: onViewHistory, // Trigger history view when clicked
        ),
      ),
    );
  }

  Widget _buildActionsCell() {
    return Expanded(
      flex: 4, // Increased flex value for more space
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: ElevatedButton(
                onPressed: onChangeDeadline,
                style: ElevatedButton.styleFrom(
                  backgroundColor: customAqua,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Adjust Deadline',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: ElevatedButton(
                onPressed: onReassignTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: customAqua,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Reassign Task',
                  style: TextStyle(
                    color: customDarkGrey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
