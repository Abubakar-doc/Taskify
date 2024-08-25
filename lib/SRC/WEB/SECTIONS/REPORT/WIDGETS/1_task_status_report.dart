import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:taskify/SRC/COMMON/SERVICES/task.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:taskify/SRC/COMMON/UTILS/Utils.dart';
import 'package:taskify/SRC/WEB/WIDGETS/small_widgets.dart';
import 'package:taskify/THEME/theme.dart';
import 'package:flutter/services.dart' show rootBundle;

class TaskStatusReportWidget extends StatefulWidget {
  const TaskStatusReportWidget({super.key});

  @override
  _TaskStatusReportWidgetState createState() => _TaskStatusReportWidgetState();
}

class _TaskStatusReportWidgetState extends State<TaskStatusReportWidget> {
  TaskCounts? _taskCounts;
  late TaskService _taskService;
  StreamSubscription<void>? _subscription;

  @override
  void initState() {
    super.initState();
    _taskService = TaskService();
    _fetchTaskCounts();
  }

  void _fetchTaskCounts() {
    _subscription = _taskService.updateTaskCounts(null, (TaskCounts counts) {
      setState(() {
        _taskCounts = counts;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _printReport() async {
    // Create your PDF document
    final pdf = pw.Document();

    // Get the current date and time
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy h:mm a');
    final formattedDate = formatter.format(now);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Add company title
              pw.Center(
                child: pw.Text(
                  'Taskify',
                  style: pw.TextStyle(
                      fontSize: 32, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20), // Space between title and report content

              // Report content
              pw.Text(
                'Task Status Report\n\n'
                'Active Tasks: ${_taskCounts?.activeCount ?? 0}\n'
                'Late Tasks: ${_taskCounts?.lateCount ?? 0}\n'
                'Under Approval Tasks: ${_taskCounts?.underApprovalCount ?? 0}\n'
                'Rejected Tasks: ${_taskCounts?.rejectedCount ?? 0}\n'
                'Completed Tasks: ${_taskCounts?.completedCount ?? 0}\n'
                'Total tasks assigned till now: ${((_taskCounts?.activeCount ?? 0) + (_taskCounts?.completedCount ?? 0) + (_taskCounts?.underApprovalCount ?? 0)).toString()}',
                style: const pw.TextStyle(fontSize: 18),
              ),
              pw.Spacer(), // Push the footer to the bottom

              // Footer
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Printed by Admin',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Printed on: $formattedDate',
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Print the document
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Task Status Report',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      // Add your share functionality here
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.print, color: Colors.white),
                    onPressed: _printReport,
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          if (_taskCounts != null)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTaskInfoCard(
                        'Active Tasks',
                        _taskCounts!.activeCount,
                        Icons.check_circle,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTaskInfoCard(
                        'Late Tasks',
                        _taskCounts!.lateCount,
                        Icons.warning,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTaskInfoCard(
                        'Under Approval Tasks',
                        _taskCounts!.underApprovalCount,
                        Icons.pending,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTaskInfoCard(
                        'Rejected Tasks',
                        _taskCounts!.rejectedCount,
                        Icons.cancel,
                        Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTaskInfoCard(
                        'Completed Tasks',
                        _taskCounts!.completedCount,
                        Icons.done_all,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: customLightGrey,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total tasks assigned till now:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            ((_taskCounts?.activeCount ?? 0) +
                                    (_taskCounts?.completedCount ?? 0) +
                                    (_taskCounts?.underApprovalCount ?? 0))
                                .toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            LoadingPlaceholder(
              height: 190,
              backgroundColor: customLightGrey,
              borderRadius: BorderRadius.circular(16),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskInfoCard(
      String label, int count, IconData icon, Color color) {
    return Card(
      color: customLightGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
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
    );
  }
}
