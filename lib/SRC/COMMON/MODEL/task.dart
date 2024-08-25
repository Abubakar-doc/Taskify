// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class Task {
//   final String id;
//   final String title;
//   final String? description;
//   final Timestamp createdAt;
//   final Timestamp updatedAt;
//   final List<Map<String, dynamic>> assignedTo;
//
//   Task({
//     required this.id,
//     required this.title,
//     this.description,
//     required this.createdAt,
//     required this.updatedAt,
//     this.assignedTo = const [],
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'createdAt': createdAt,
//       'updatedAt': updatedAt,
//       'assigned': assignedTo,
//     };
//   }
//
//   factory Task.fromMap(Map<String, dynamic> map, String id) {
//     return Task(
//       id: id,
//       title: map['title'] as String? ?? '',
//       description: map['description'] as String?,
//       createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
//       updatedAt: map['updatedAt'] as Timestamp? ?? Timestamp.now(),
//       assignedTo: List<Map<String, dynamic>>.from(map['assigned'] ?? []),
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final List<Map<String, dynamic>>? assignedTo;  // Nullable

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.assignedTo,  // Nullable
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'assignedTo': assignedTo ?? [],  // Default to empty list if null
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: map['updatedAt'] as Timestamp? ?? Timestamp.now(),
      assignedTo: map['assignedTo'] != null
          ? List<Map<String, dynamic>>.from(map['assignedTo'])
          : null,
    );
  }
}
