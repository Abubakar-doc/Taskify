import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taskify/SRC/COMMON/SERVICES/task.dart';
import 'package:taskify/SRC/MOBILE/UTILS/mobile_utils.dart';
import 'package:taskify/SRC/WEB/WIDGETS/small_widgets.dart';
import 'package:taskify/THEME/theme.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  final String memberId;
  final String title;
  final String description;
  final String deadline;
  final String status;
  final Timestamp dateAssigned;
  final Timestamp? dateCompleted;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    required this.memberId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
    required this.dateAssigned,
    this.dateCompleted,
  });

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TaskService _taskService = TaskService();
  late Stream<List<Map<String, dynamic>>> _taskStream;
  late String formattedDateTimeAssigned;
  late String formattedDateTimeCompleted;

  @override
  void initState() {
    super.initState();
    _taskStream = _taskService.getTaskResponsesStreamForMember(
        widget.memberId, widget.taskId);
    final dateAssigned =
        DateTime.fromMillisecondsSinceEpoch(widget.dateAssigned.seconds * 1000);
    final dateCompleted = widget.dateCompleted != null
        ? DateTime.fromMillisecondsSinceEpoch(
            widget.dateCompleted!.seconds * 1000)
        : null;
    final dateTimeFormat = DateFormat('dd-MM-yyyy, hh:mm a');
    formattedDateTimeAssigned = dateTimeFormat.format(dateAssigned);
    formattedDateTimeCompleted = dateCompleted != null
        ? dateTimeFormat.format(dateCompleted)
        : 'Not completed';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deadlineDate = DateTime.parse(widget.deadline);
    final now = DateTime.now();
    DateTime deadlineOnlyDate =
        DateTime(deadlineDate.year, deadlineDate.month, deadlineDate.day);
    DateTime nowOnlyDate = DateTime(now.year, now.month, now.day);
    final isMissed = deadlineOnlyDate.isBefore(nowOnlyDate);
    final isCompleted = widget.status == 'Completed';
    final isUnderApproval = widget.status == 'Under Approval';
    final isRejected = widget.status == 'Rejected';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: customDarkGrey,
        title: const Text(
          'Task Details',
          style: TextStyle(color: customAqua),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: customAqua,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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
                            const TextSpan(text: 'Date/Time Assigned: '),
                            TextSpan(
                              text: formattedDateTimeAssigned,
                              style: const TextStyle(
                                color: Colors.white,
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
                            const TextSpan(text: 'Deadline: '),
                            TextSpan(
                              text: DateFormat.yMMMd().format(deadlineDate),
                              style: TextStyle(
                                color:
                                    isMissed && !isCompleted && !isUnderApproval
                                        ? Colors.red.shade400
                                        : Colors.white,
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
                            const TextSpan(text: 'Status: '),
                            TextSpan(
                              text: widget.status,
                              style: TextStyle(
                                color: isRejected
                                    ? Colors.red
                                    : isCompleted
                                        ? Colors.green
                                        : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCompleted)
                        Column(
                          children: [
                            const SizedBox(height: 16),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                                children: <TextSpan>[
                                  const TextSpan(text: 'Date/Time Completed: '),
                                  TextSpan(
                                    text: formattedDateTimeCompleted,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      const divider(),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: customDarkGrey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Chat',
                                style: TextStyle(
                                  color: customAqua,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              StreamBuilder<List<Map<String, dynamic>>>(
                                stream: _taskStream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator(
                                      color: customAqua,
                                    ));
                                  } else if (snapshot.hasError) {
                                    return const Center(
                                        child: Text('Error loading messages'));
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Center(
                                        child: Text('No messages yet'));
                                  } else {
                                    return _buildChatMessages(snapshot.data!);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              if (!isCompleted && !isUnderApproval)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _messageController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Add a message',
                          filled: true,
                          fillColor: customLightGrey,
                          contentPadding:
                              const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: customAqua),
                          ),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Message cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
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
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  try {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      await _taskService.submitTaskForApproval(
                                        widget.memberId,
                                        widget.taskId,
                                        _messageController.text,
                                      );
                                      MobUtils.showSuccessToast(context,
                                          'Task submitted successfully. Awaiting approval.');
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                    MobUtils.showFailureToast(
                                        context, 'Error submitting task: $e');
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                },
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  isMissed ? 'Submit late' : 'Submit',
                                  style: const TextStyle(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatMessages(List<Map<String, dynamic>> responses) {
    DateTime? previousDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: responses.map((response) {
        final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
            response['timestamp'].seconds * 1000);
        final String formattedDate = _formatChatDate(timestamp);
        final String role = response['role'] ?? 'Unknown';
        final String text = response['response'] ?? '';
        bool isSameDate =
            previousDate != null && _isSameDate(previousDate!, timestamp);

        final messageWidget = Column(
          crossAxisAlignment: role == 'user'
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isSameDate)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ),
            Align(
              alignment:
                  role == 'user' ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7),
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
                            text: '${role == 'admin' ? role : 'You'} ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text:
                                '(${DateFormat('hh:mm a').format(timestamp)})',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
        previousDate = timestamp;
        return messageWidget;
      }).toList(),
    );
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatChatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (_isSameDate(date, now)) {
      return 'Today';
    } else if (_isSameDate(date, yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }
}
