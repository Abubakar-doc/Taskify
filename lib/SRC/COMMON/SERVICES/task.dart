import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskify/SRC/COMMON/MODEL/task.dart';

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
    final allTasksStream = _firestore
        .collection(_taskCollectionName)
        .orderBy('updatedAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromMap(doc.data(), doc.id))
          .toList();
    });

    final pendingAssignedTasksStream =
        getAllPendingAndCompleteAssignedTasksWithUserNames()
            .map((tasksMap) => tasksMap.keys.toSet());

    return Rx.combineLatest2(
      allTasksStream,
      pendingAssignedTasksStream,
      (List<Task> allTasks, Set<String> assignedTaskIds) {
        return allTasks.where((task) {
          // print(task.id);
          return !assignedTaskIds.contains(task.id);
        }).toList();
      },
    );
  }

  Stream<Map<String, Map<String, dynamic>>>
      getAllPendingAndCompleteAssignedTasksWithUserNames() {
    final userCollectionStream =
        FirebaseFirestore.instance.collection(_userCollectionName).snapshots();

    return userCollectionStream.transform(
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
          Map<String, Map<String, dynamic>>>.fromHandlers(
        handleData: (snapshot, sink) {
          final tasksWithUserNames = <String, Map<String, dynamic>>{};

          for (var userDoc in snapshot.docs) {
            final userData = userDoc.data();
            final userName = userData['name'] as String? ?? 'Unknown';
            final tasks = userData['tasks'] as Map<String, dynamic>? ?? {};

            tasks.forEach((taskId, taskDetails) {
              if (taskDetails is Map) {
                final taskStatus = taskDetails['status'] as String?;
                if (taskStatus == 'pending' || taskStatus == 'Completed') {
                  tasksWithUserNames[taskId] = {
                    'taskDetails': Map<String, dynamic>.from(taskDetails),
                    'userName': userName,
                    'documentId': userDoc.id,
                  };
                }
              }
            });
          }

          sink.add(tasksWithUserNames);
        },
        handleError: (error, stackTrace, sink) {
          sink.addError(error, stackTrace);
        },
      ),
    );
  }

  Stream<Map<String, Map<String, dynamic>>>
      getAllPendingAssignedTasksWithUserNames() {
    final userCollectionStream =
        FirebaseFirestore.instance.collection(_userCollectionName).snapshots();

    return userCollectionStream.transform(
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
          Map<String, Map<String, dynamic>>>.fromHandlers(
        handleData: (snapshot, sink) {
          final tasksWithUserNames = <String, Map<String, dynamic>>{};

          for (var userDoc in snapshot.docs) {
            final userData = userDoc.data();
            final userName = userData['name'] as String? ?? 'Unknown';
            final tasks = userData['tasks'] as Map<String, dynamic>? ?? {};

            tasks.forEach((taskId, taskDetails) {
              if (taskDetails is Map) {
                final taskStatus = taskDetails['status'] as String?;
                if (taskStatus == 'pending' &&
                    taskStatus != 'Completed' &&
                    taskStatus != 'Under Approval') {
                  tasksWithUserNames[taskId] = {
                    'taskDetails': Map<String, dynamic>.from(taskDetails),
                    'userName': userName,
                    'documentId': userDoc.id,
                  };
                }
              }
            });
          }

          sink.add(tasksWithUserNames);
        },
        handleError: (error, stackTrace, sink) {
          sink.addError(error, stackTrace);
        },
      ),
    );
  }

  Stream<Map<String, Map<String, dynamic>>>
  getAllUnderApprovalAssignedTasksWithUserNames() {
    final userCollectionStream =
    FirebaseFirestore.instance.collection(_userCollectionName).snapshots();

    return userCollectionStream.transform(
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
          Map<String, Map<String, dynamic>>>.fromHandlers(
        handleData: (snapshot, sink) {
          final tasksWithUserNames = <String, Map<String, dynamic>>{};

          for (var userDoc in snapshot.docs) {
            final userData = userDoc.data();
            final userName = userData['name'] as String? ?? 'Unknown';
            final tasks = userData['tasks'] as Map<String, dynamic>? ?? {};

            tasks.forEach((taskId, taskDetails) {
              if (taskDetails is Map) {
                final taskStatus = taskDetails['status'] as String?;
                if (taskStatus != 'pending' &&
                    taskStatus != 'Completed' &&
                    taskStatus == 'Under Approval') {
                  tasksWithUserNames[taskId] = {
                    'taskDetails': Map<String, dynamic>.from(taskDetails),
                    'userName': userName,
                    'documentId': userDoc.id,
                  };
                }
              }
            });
          }

          sink.add(tasksWithUserNames);
        },
        handleError: (error, stackTrace, sink) {
          sink.addError(error, stackTrace);
        },
      ),
    );
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

  Stream<Map<String, String>> getTaskNamesByIds(
      List<String> taskIds) {
    // Return an empty map if there are no task IDs to query.
    if (taskIds.isEmpty) {
      return Stream.value({});
    }

    return _firestore
        .collection(_taskCollectionName)
        .where(FieldPath.documentId, whereIn: taskIds)
        .snapshots()
        .map((snapshot) {
      // Map each document to a key-value pair where the key is the document ID
      // and the value is the task title (or 'Unnamed Task' if the title is missing).
      return Map.fromEntries(
        snapshot.docs.map((doc) {
          // Ensure that doc.data() contains the 'title' key and is a String.
          final title = doc.data().containsKey('title')
              ? doc.data()['title'] as String
              : 'Unnamed Task';
          return MapEntry(doc.id, title);
        }),
      );
    }).handleError((error) {
      // Handle errors such as network issues, permission errors, etc.
      print('Error fetching task names: $error');
      return {}; // Return an empty map in case of error.
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

  Stream<Map<String, dynamic>> getTasksStreamForMember(String memberId) {
    // Create a stream for the user's task data
    final userTasksStream = _firestore
        .collection(_userCollectionName)
        .doc(memberId)
        .snapshots()
        .map((userDoc) {
      if (!userDoc.exists) {
        throw Exception('User with ID $memberId not found.');
      }

      final userData = userDoc.data();
      if (userData == null) {
        throw Exception('User data is empty.');
      }

      // Extract tasks
      final tasks = userData['tasks'] as Map<String, dynamic>? ?? {};
      return tasks;
    });

    // Create a stream for task details
    Stream<Map<String, Task>> taskDetailsStream(List<String> taskIds) {
      if (taskIds.isEmpty) {
        return Stream.value({});
      }

      return _firestore
          .collection(_taskCollectionName)
          .where(FieldPath.documentId, whereIn: taskIds)
          .snapshots()
          .map((snapshot) {
        return Map.fromEntries(snapshot.docs.map((doc) {
          final task = Task.fromMap(doc.data(), doc.id);
          return MapEntry(doc.id, task);
        }));
      });
    }

    return userTasksStream.switchMap((tasks) {
      final taskIds = tasks.keys.toList();
      return taskDetailsStream(taskIds).map((taskDetails) {
        final result = <String, dynamic>{};

        // Collect tasks with details
        final taskList = <MapEntry<String, dynamic>>[];
        tasks.forEach((taskId, taskData) {
          final task = taskDetails[taskId];
          if (task != null) {
            taskList.add(MapEntry(taskId, {
              'title': task.title,
              'description': task.description,
              'status': taskData['status'],
              'deadline': taskData['deadline'],
            }));
          }
        });

        // Sort tasks by deadline (assuming deadline is a string in 'yyyy-MM-dd' format)
        taskList.sort((a, b) {
          final deadlineA = a.value['deadline'];
          final deadlineB = b.value['deadline'];
          return deadlineA.compareTo(deadlineB);
        });

        // Convert sorted task list back to a map
        taskList.forEach((entry) {
          result[entry.key] = entry.value;
        });

        return result;
      });
    });
  }

  Future<void> submitTaskForApproval(
    String memberId,
    String taskId,
  ) async {
    // Fetch the user's document
    final userQuery = await _firestore
        .collection(_userCollectionName)
        .where('uid', isEqualTo: memberId)
        .get();

    if (userQuery.docs.isNotEmpty) {
      final userDoc = userQuery.docs.first.reference;
      final userData = await userDoc.get();

      // Get the current tasks of the user
      final currentTasks =
          Map<String, dynamic>.from(userData.data()?['tasks'] ?? {});

      if (currentTasks.containsKey(taskId)) {
        // Update the status of the task to 'underApproval'
        currentTasks[taskId]['status'] = 'Under Approval';

        // Update the user's tasks in the Firestore document
        await userDoc.update({
          'tasks': currentTasks,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Retrieve the task document to update the status in the task collection
        final taskDocRef =
            _firestore.collection(_taskCollectionName).doc(taskId);
        final taskDoc = await taskDocRef.get();

        if (taskDoc.exists) {
          await taskDocRef.update({
            'status': 'underApproval',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        throw Exception('Task ID $taskId not found for this member.');
      }
    } else {
      throw Exception('Member with ID $memberId not found.');
    }
  }

  Future<void> passTask(
      String memberId,
      String taskId,
      ) async {
    // Fetch the user's document
    final userQuery = await _firestore
        .collection(_userCollectionName)
        .where('uid', isEqualTo: memberId)
        .get();

    if (userQuery.docs.isNotEmpty) {
      final userDoc = userQuery.docs.first.reference;
      final userData = await userDoc.get();

      // Get the current tasks of the user
      final currentTasks =
      Map<String, dynamic>.from(userData.data()?['tasks'] ?? {});

      if (currentTasks.containsKey(taskId)) {
        // Update the status of the task to 'underApproval'
        currentTasks[taskId]['status'] = 'Completed';

        // Update the user's tasks in the Firestore document
        await userDoc.update({
          'tasks': currentTasks,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Retrieve the task document to update the status in the task collection
        final taskDocRef =
        _firestore.collection(_taskCollectionName).doc(taskId);
        final taskDoc = await taskDocRef.get();

        if (taskDoc.exists) {
          await taskDocRef.update({
            'status': 'underApproval',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        throw Exception('Task ID $taskId not found for this member.');
      }
    } else {
      throw Exception('Member with ID $memberId not found.');
    }
  }

  Future<void> rejectTask(
      String memberId,
      String taskId,
      ) async {
    // Fetch the user's document
    final userQuery = await _firestore
        .collection(_userCollectionName)
        .where('uid', isEqualTo: memberId)
        .get();

    if (userQuery.docs.isNotEmpty) {
      final userDoc = userQuery.docs.first.reference;
      final userData = await userDoc.get();

      // Get the current tasks of the user
      final currentTasks =
      Map<String, dynamic>.from(userData.data()?['tasks'] ?? {});

      if (currentTasks.containsKey(taskId)) {
        // Update the status of the task to 'underApproval'
        currentTasks[taskId]['status'] = 'Rejected';

        // Update the user's tasks in the Firestore document
        await userDoc.update({
          'tasks': currentTasks,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Retrieve the task document to update the status in the task collection
        final taskDocRef =
        _firestore.collection(_taskCollectionName).doc(taskId);
        final taskDoc = await taskDocRef.get();

        if (taskDoc.exists) {
          await taskDocRef.update({
            'status': 'underApproval',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        throw Exception('Task ID $taskId not found for this member.');
      }
    } else {
      throw Exception('Member with ID $memberId not found.');
    }
  }
}
