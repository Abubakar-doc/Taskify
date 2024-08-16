import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String departmentId;
  final Map<String, Map<String, String>> tasks;
  String status;
  final DateTime createdAt;
  DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.departmentId = '',
    this.tasks = const {},
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'departmentId': departmentId,
      'tasks': tasks,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      departmentId: map['departmentId'] ?? '',
      tasks: _parseTasks(map['tasks'] ?? {}),
      status: map['status'] ?? 'pending',
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  // Helper method to parse tasks
  static Map<String, Map<String, String>> _parseTasks(dynamic tasks) {
    if (tasks is Map) {
      final Map<String, Map<String, String>> parsedTasks = {};
      tasks.forEach((key, value) {
        if (value is Map) {
          parsedTasks[key] = Map<String, String>.from(value);
        }
      });
      return parsedTasks;
    }
    return {};
  }

  // Helper method to parse timestamp
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return DateTime.now();
  }
}
