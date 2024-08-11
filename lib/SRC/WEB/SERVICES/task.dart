import 'dart:async';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskify/SRC/WEB/MODEL/task.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _taskCollectionName = 'Task';
  final String _userCollectionName = 'Users';

  Future<void> createTask(Task task) async {
    await _firestore.collection(_taskCollectionName).add({
      ...task.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Task>> getTasksStream() {
    return _firestore
        .collection(_taskCollectionName)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<Task>> getTasksStreamForAssigningTask() {
    // Stream of all tasks
    final allTasksStream = _firestore
        .collection(_taskCollectionName)
        .orderBy('updatedAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromMap(doc.data(), doc.id))
          .toList();
    });

    // Stream of pending assigned tasks
    final pendingAssignedTasksStream = getAllPendingAssignedTasksWithUserNames()
        .map((tasksMap) => tasksMap.keys.toSet());

    return StreamZip([allTasksStream, pendingAssignedTasksStream])
        .map((values) {
      final allTasks = values[0] as List<Task>;
      final assignedTaskIds = values[1] as Set<String>;

      return allTasks.where((task) {
        return !assignedTaskIds.contains(task.id);
      }).toList();
    });
  }

  Future<void> updateTask(Task task) async {
    await _firestore.collection(_taskCollectionName).doc(task.id).update({
      ...task.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTask(String id) async {
    await _firestore.collection(_taskCollectionName).doc(id).delete();
  }

  Future<void> assignTaskToMember(
    String memberId,
    String taskId,
    String deadline,
    String memberName,
  ) async {
    final userQuery = await _firestore
        .collection(_userCollectionName)
        .where('uid', isEqualTo: memberId)
        .get();

    if (userQuery.docs.isNotEmpty) {
      final userDoc = userQuery.docs.first.reference;
      final userData = await userDoc.get();

      final currentTasks =
          Map<String, dynamic>.from(userData.data()?['tasks'] ?? {});

      if (!currentTasks.containsKey(taskId)) {
        currentTasks[taskId] = {
          'status': 'pending',
          'deadline': deadline,
        };

        await userDoc.update({
          'tasks': currentTasks,
        });

        // Retrieve the task document to update the assigned list
        final taskDocRef = _firestore.collection('Task').doc(taskId);
        final taskDoc = await taskDocRef.get();
        final taskData = taskDoc.data();

        // Ensure assignedTo is a list of maps
        List<Map<String, dynamic>> assignedList =
            List<Map<String, dynamic>>.from(taskData?['assignedTo'] ?? []);

        // Check if the memberId is already in the list
        if (!assignedList.any((entry) => entry['memberId'] == memberId)) {
          assignedList.add({
            'memberId': memberId,
            'timestamp': Timestamp.now(), // Add the current timestamp
          });

          await taskDocRef.update({
            'assignedTo': assignedList,
          });
        }
      } else {
        throw Exception('This Task is already assigned to this member.');
      }
    } else {
      throw Exception('Member named $memberName not found.');
    }
  }

  Stream<Map<String, Map<String, dynamic>>>
      getAllPendingAssignedTasksWithUserNames() {
    final userCollectionStream =
        FirebaseFirestore.instance.collection(_userCollectionName).snapshots();

    return userCollectionStream.transform(
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
          Map<String, Map<String, dynamic>>>.fromHandlers(
        handleData: (snapshot, sink) {
          final pendingTasksWithUserNames = <String, Map<String, dynamic>>{};

          for (var userDoc in snapshot.docs) {
            final userData = userDoc.data();
            final userName = userData['name'] as String? ?? 'Unknown';
            final tasks = userData['tasks'] as Map<String, dynamic>? ?? {};

            tasks.forEach((taskId, taskDetails) {
              if (taskDetails is Map && taskDetails['status'] == 'pending') {
                pendingTasksWithUserNames[taskId] = {
                  'taskDetails': Map<String, dynamic>.from(taskDetails),
                  'userName': userName,
                  'documentId': userDoc.id,
                };
              }
            });
          }

          sink.add(pendingTasksWithUserNames);
        },
        handleError: (error, stackTrace, sink) {
          sink.addError(error, stackTrace);
        },
      ),
    );
  }

  Stream<Map<String, String>> getTaskNamesByIds(List<String> taskIds) {
    if (taskIds.isEmpty) {
      // Return an empty map if there are no task IDs to query.
      return Stream.value({});
    }

    return _firestore
        .collection(_taskCollectionName)
        .where(FieldPath.documentId, whereIn: taskIds)
        .snapshots()
        .map((snapshot) {
      return Map.fromEntries(snapshot.docs.map((doc) {
        return MapEntry(
            doc.id, doc.data()['title'] as String? ?? 'Unnamed Task');
      }));
    });
  }

  Future<void> reallocateTask(
    String taskId,
    String newMemberId,
    String deadline,
    String currentUserId,
  ) async {
    final newUserDoc =
        _firestore.collection(_userCollectionName).doc(newMemberId);
    final newUserData = await newUserDoc.get();

    if (newUserData.exists) {
      // Remove the task from the current user's task list
      final currentUserDoc =
          _firestore.collection(_userCollectionName).doc(currentUserId);
      final currentUserData = await currentUserDoc.get();
      final currentTasks =
          Map<String, dynamic>.from(currentUserData.data()?['tasks'] ?? {});
      currentTasks.remove(taskId);
      await currentUserDoc.update({
        'tasks': currentTasks,
      });

      // Add the task to the new user's task list
      final newTasks =
          Map<String, dynamic>.from(newUserData.data()?['tasks'] ?? {});
      newTasks[taskId] = {
        'status': 'pending',
        'deadline': deadline,
      };
      await newUserDoc.update({
        'tasks': newTasks,
      });

      // Update the assignedTo array in the Task document
      final taskDocRef = _firestore.collection(_taskCollectionName).doc(taskId);
      final taskDoc = await taskDocRef.get();
      final taskData = taskDoc.data();

      if (taskData != null) {
        List<Map<String, dynamic>> assignedList =
            List<Map<String, dynamic>>.from(taskData['assignedTo'] ?? []);
        assignedList.add({
          'memberId': newMemberId,
          'timestamp': Timestamp.now(),
        });

        await taskDocRef.update({
          'assignedTo': assignedList,
        });
      }
    } else {
      throw Exception('User with ID $newMemberId not found.');
    }
  }

  Stream<Map<String, List<Map<String, dynamic>>>> getAssignedToByTaskIds(
      List<String> taskIds) {
    if (taskIds.isEmpty) {
      return Stream.value({});
    }

    return _firestore
        .collection(_taskCollectionName)
        .where(FieldPath.documentId, whereIn: taskIds)
        .snapshots()
        .map((snapshot) {
      final assignedToMap = <String, List<Map<String, dynamic>>>{};

      for (var doc in snapshot.docs) {
        final taskData = doc.data();
        final assignedTo =
            List<Map<String, dynamic>>.from(taskData['assignedTo'] ?? []);
        assignedToMap[doc.id] = assignedTo;
      }

      return assignedToMap;
    });
  }

  Future<void> updateTaskDeadline(
    String taskId,
    String memberId,
    String newDeadline,
  ) async {
    // Get the user document
    final userDocRef = _firestore.collection(_userCollectionName).doc(memberId);
    final userDoc = await userDocRef.get();

    if (userDoc.exists) {
      final userData = userDoc.data();
      final tasks = Map<String, dynamic>.from(userData?['tasks'] ?? {});

      if (tasks.containsKey(taskId)) {
        // Update the deadline for the specific task
        tasks[taskId]['deadline'] = newDeadline;

        // Update the user document with the new deadline
        await userDocRef.update({
          'tasks': tasks,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        throw Exception('Task ID $taskId not found for this user.');
      }
    } else {
      throw Exception('User with ID $memberId not found.');
    }
  }
}
