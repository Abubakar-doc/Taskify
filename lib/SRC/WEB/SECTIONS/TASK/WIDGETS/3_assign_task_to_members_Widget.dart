import 'package:flutter/material.dart';
import 'package:taskify/SRC/COMMON/MODEL/Member.dart';
import 'package:taskify/SRC/COMMON/UTILS/Utils.dart';
import 'package:taskify/SRC/WEB/SERVICES/member.dart';
import 'package:taskify/THEME/theme.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:taskify/SRC/WEB/SERVICES/task.dart';
import 'package:taskify/SRC/WEB/MODEL/task.dart';

class AssignTasksToMembersWidget extends StatefulWidget {
  const AssignTasksToMembersWidget({super.key});

  @override
  _AssignTasksToMembersWidgetState createState() =>
      _AssignTasksToMembersWidgetState();
}

class _AssignTasksToMembersWidgetState
    extends State<AssignTasksToMembersWidget> {
  final TaskService _taskService = TaskService();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _taskDescriptionController =
      TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _memberController = TextEditingController();
  final TextEditingController _memberEmailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Task> taskList = [];
  bool isLoadingMembers = true;
  Task? selectedTask;
  UserModel? selectedMember;
  bool isLoading = true;
  final MemberService _memberService = MemberService();
  List<UserModel> memberList = [];

  @override
  void initState() {
    super.initState();
    _taskService.getTasksStreamForAssigningTask().listen((tasks) {
      setState(() {
        taskList = tasks;
        isLoading = false;
      });
    });

    _memberService.getApprovedMembersHavingDepartment().listen((members) {
      setState(() {
        memberList = members;
        isLoadingMembers = false;
      });
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    _taskDescriptionController.dispose();
    _deadlineController.dispose();
    _memberController.dispose();
    _memberEmailController.dispose();
    super.dispose();
  }

  void handleCancel() {
    setState(() {
      _taskController.clear();
      _taskDescriptionController.clear();
      _deadlineController.clear();
      _memberController.clear();
      _memberEmailController.clear();
      selectedTask = null;
      selectedMember = null;
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

  List<UserModel> getMemberSuggestions(String query) {
    if (isLoadingMembers) {
      return [];
    } else if (memberList.isEmpty) {
      return [];
    }
    return memberList
        .where(
            (member) => member.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate,
      lastDate: DateTime(currentDate.year + 5),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            primaryColor: customAqua,
            hintColor: customAqua,
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            dialogBackgroundColor: customLightGrey,
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: customLightGrey,
              headerHelpStyle:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _deadlineController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
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
                  hintText: 'Search Unassigned Task',
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
                if (suggestion == 'Loading...') {
                  return const ListTile(
                    title: Text('Loading...'),
                  );
                } else if (suggestion == 'No tasks found') {
                  return const ListTile(
                    title: Text('No tasks found'),
                  );
                } else {
                  final task =
                      taskList.firstWhere((task) => task.title == suggestion);
                  return ListTile(
                    title: Text(task.title),
                    subtitle: Text(
                      task.description != null
                          ? '${task.description!.substring(0, task.description!.length > 50 ? 50 : task.description!.length)}${task.description!.length > 50 ? '...' : ''}'
                          : '',
                      overflow: TextOverflow.ellipsis,
                    ),
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
                    suggestion != 'No tasks found') {
                  final task =
                      taskList.firstWhere((task) => task.title == suggestion);
                  setState(() {
                    selectedTask = task;
                    _taskController.text = suggestion;
                    _taskDescriptionController.text = task.description ?? '';
                  });
                }
              },
              displayAllSuggestionWhenTap: true,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    value == 'Loading...' ||
                    value == 'No tasks found') {
                  return 'Please select a Task';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _taskDescriptionController,
              enabled: false,
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
                if (isLoadingMembers) {
                  return ['Loading...'];
                } else if (memberList.isEmpty) {
                  return ['No members found'];
                }
                return getMemberSuggestions(pattern)
                    .map((member) => member.name)
                    .toList();
              },
              itemBuilder: (context, String suggestion) {
                if (suggestion == 'Loading...') {
                  return const ListTile(
                    title: Text('Loading...'),
                  );
                } else if (suggestion == 'No members found') {
                  return const ListTile(
                    title: Text('No members found'),
                  );
                } else {
                  final member = memberList
                      .firstWhere((member) => member.name == suggestion);
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
                  final member = memberList
                      .firstWhere((member) => member.name == suggestion);
                  setState(() {
                    selectedMember = member;
                    _memberController.text = member.name;
                    _memberEmailController.text = member.email;
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
              controller: _memberEmailController,
              enabled: false,
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
            const Text(
              'Deadline',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _deadlineController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: customLightGrey,
                    hintText: 'Date of deadline',
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
                ),
              ),
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
                              if (selectedTask != null &&
                                  selectedMember != null &&
                                  _deadlineController.text.isNotEmpty) {
                                _assignTaskToMemberConfirmationDialog(
                                  context,
                                  selectedMember!,
                                  selectedTask!,
                                  _deadlineController.text, // Pass the deadline
                                );
                              }
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

  void _assignTaskToMemberConfirmationDialog(
      BuildContext context,
      UserModel member,
      Task task,
      String deadline // Include the deadline in the dialog
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: const Text('Assign Tasks to Members'),
              backgroundColor: customLightGrey,
              content: Text(
                'Are you sure you want to assign ${task.title} to ${member.name} with a deadline of $deadline?',
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
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            await _taskService.assignTaskToMember(member.uid,
                                selectedTask!.id!, deadline, member.name);
                            Navigator.of(context).pop();
                            Utils().SuccessSnackBar(
                              context,
                              'The task "${task.title}" has been successfully assigned to the member "${member.name}".',
                            );
                            handleCancel();
                          } catch (error) {
                            Navigator.of(context).pop();
                            String errorMessage;
                            if (error is Exception) {
                              errorMessage = error.toString();
                            } else {
                              errorMessage =
                                  'An unexpected error occurred. Please try again.';
                            }
                            print(error);
                            Utils().ErrorSnackBar(
                              context,
                              ' $errorMessage Failed to assign the task "${task.title}" to "${member.name}".',
                            );
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
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
                          'Assign',
                          style: TextStyle(color: Colors.black),
                        ),
                )
              ],
            );
          },
        );
      },
    );
  }
}
