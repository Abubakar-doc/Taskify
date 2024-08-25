import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskify/SRC/COMMON/MODEL/task.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _taskCollectionName = 'Task';
  final String _userCollectionName = 'Users';

  Future<void> createTask(Task task) async {
    // Step 1: Generate a new document reference with a unique ID
    DocumentReference docRef = _firestore.collection(_taskCollectionName).doc();

    // Step 2: Set the taskId in the task object and assign timestamps
    Task updatedTask = Task(
      id: docRef.id,
      title: task.title,
      description: task.description,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    // Step 3: Add the task data with the generated taskId
    await docRef.set(updatedTask.toMap());
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

  Stream<List<String>> getTasksWithSpecificStatusStream() {
    final userCollectionStream =
        _firestore.collection(_userCollectionName).snapshots();

    return userCollectionStream.transform(
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
          List<String>>.fromHandlers(
        handleData: (snapshot, sink) {
          final excludedTaskIds = <String>{};

          for (var userDoc in snapshot.docs) {
            final userData = userDoc.data();
            final tasks = userData['tasks'] as Map<String, dynamic>? ?? {};

            tasks.forEach((taskId, taskDetails) {
              final taskStatus = taskDetails['status'] as String?;
              if (taskStatus == 'Under Approval' || taskStatus == 'Completed') {
                excludedTaskIds.add(taskId);
              }
            });
          }

          sink.add(excludedTaskIds.toList());
        },
        handleError: (error, stackTrace, sink) {
          sink.addError(error, stackTrace);
        },
      ),
    );
  }

  Stream<Map<String, Map<String, dynamic>>> getTasksByStatus(
      List<String> statuses) {
    final userCollectionStream =
        _firestore.collection(_userCollectionName).snapshots();

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
                if (statuses.contains(taskStatus)) {
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

  Stream<List<Task>> getFilteredTasksStream() {
    final allTasksStream = getTasksStream();

    final excludedTasksStream =
        getTasksWithSpecificStatusStream().map((taskIds) => taskIds.toSet());

    return Rx.combineLatest2<List<Task>, Set<String>, List<Task>>(
      allTasksStream,
      excludedTasksStream,
      (allTasks, excludedTaskIds) {
        return allTasks.where((task) {
          // Include only tasks that are not in the excluded status list
          return !excludedTaskIds.contains(task.id);
        }).toList();
      },
    );
  }

  Stream<List<Task>> getTasksStreamForAssigningTask() {
    return _firestore
        .collection(_taskCollectionName)
        .orderBy('updatedAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromMap(doc.data(), doc.id))
          .where((task) {
        // Check if 'assignedTo' list is null or empty
        final assignedTo = task.assignedTo;
        return assignedTo == null || assignedTo.isEmpty;
      }).toList();
    });
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
                if (taskStatus == 'pending' ||
                    taskStatus == 'Rejected' &&
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
    // Reference to the task document
    final taskDocRef = _firestore.collection(_taskCollectionName).doc(id);

    // Get the task document
    final taskDoc = await taskDocRef.get();

    if (taskDoc.exists) {
      final taskData = taskDoc.data();
      // Check if the assignedTo list is not null and contains any entries
      final assignedTo =
          List<Map<String, dynamic>>.from(taskData?['assignedTo'] ?? []);

      if (assignedTo.isNotEmpty) {
        // Throw an exception if the task is assigned to someone
        throw Exception(
            'This task cannot be deleted as it is assigned to a member.');
      } else {
        // Delete the task if it is not assigned to anyone
        await taskDocRef.delete();
      }
    } else {
      throw Exception('Task with ID $id does not exist.');
    }
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
          'dateAssigned': Timestamp.now(), // Initialize dateAssigned
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

  Stream<Map<String, String>> getTaskNamesByIds(List<String> taskIds) {
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

  Stream<Map<String, Map<String, String>>> getTaskNameDescriptionByIds(
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
      // and the value is a map containing 'title' and 'description' fields.
      return Map.fromEntries(
        snapshot.docs.map((doc) {
          final data = doc.data();
          final title = data.containsKey('title')
              ? data['title'] as String
              : 'Unnamed Task';
          final description = data.containsKey('description')
              ? data['description'] as String
              : 'No description available';

          return MapEntry(
            doc.id,
            {
              'title': title,
              'description': description,
            },
          );
        }),
      );
    }).handleError((error) {
      // Handle errors such as network issues, permission errors, etc.
      print('Error fetching task details: $error');
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

  Stream<List<Map<String, dynamic>>> getTaskResponsesStreamForMember(
      String memberId, String taskId) {
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

    return userTasksStream.switchMap((tasks) {
      // Check if the taskId exists in the user's tasks
      if (!tasks.containsKey(taskId)) {
        throw Exception('Task with ID $taskId not found for user $memberId.');
      }

      // Fetch only the responses for the specific taskId
      final responses = tasks[taskId]['responses'] as List<dynamic>? ?? [];

      // Map responses to a list of maps containing the response details
      final responseList = responses.map((response) {
        return {
          'response': response['response'],
          'role': response['role'],
          'timestamp': response['timestamp'],
        };
      }).toList();

      return Stream.value(responseList);
    });
  }

  Future<void> submitTaskForApproval(
    String memberId,
    String taskId,
    String? userResponse,
  ) async {
    // Fetch the current server timestamp
    final serverTimestamp = Timestamp.now();

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
        // Retrieve the responses list
        List<Map<String, dynamic>> responses = List<Map<String, dynamic>>.from(
          currentTasks[taskId]['responses'] ?? [],
        );

        // Add the new response to the list if it's not null
        if (userResponse != null) {
          responses.add({
            'role': 'user',
            'response': userResponse,
            'timestamp': serverTimestamp,
          });
        }

        // Update the task's status and responses list
        currentTasks[taskId]['status'] = 'Under Approval';
        currentTasks[taskId]['responses'] = responses;

        // Update the user's tasks in the Firestore document
        await userDoc.update({
          'tasks': currentTasks,
          'updatedAt': serverTimestamp,
        });
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
    String? adminResponse,
  ) async {
    // Fetch the current server timestamp
    final serverTimestamp = Timestamp.now();

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
        // Retrieve the responses list
        List<Map<String, dynamic>> responses = List<Map<String, dynamic>>.from(
          currentTasks[taskId]['responses'] ?? [],
        );

        // Add the admin response to the responses list if it's not null or empty
        if (adminResponse != null && adminResponse.isNotEmpty) {
          responses.add({
            'role': 'admin',
            'response': adminResponse,
            'timestamp': serverTimestamp,
          });
        }

        // Update the task's status and responses list
        currentTasks[taskId]['status'] = 'Completed';
        currentTasks[taskId]['dateCompleted'] = serverTimestamp;
        currentTasks[taskId]['responses'] = responses;

        // Update the user's tasks in the Firestore document
        await userDoc.update({
          'tasks': currentTasks,
          'updatedAt': serverTimestamp,
        });
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
    String? adminResponse,
  ) async {
    // Fetch the current server timestamp
    final serverTimestamp = Timestamp.now();

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
        // Retrieve the responses list
        List<Map<String, dynamic>> responses = List<Map<String, dynamic>>.from(
          currentTasks[taskId]['responses'] ?? [],
        );

        // Add the admin response to the responses list if it's not null or empty
        if (adminResponse != null && adminResponse.isNotEmpty) {
          responses.add({
            'role': 'admin',
            'response': adminResponse,
            'timestamp': serverTimestamp,
          });
        }

        // Update the task's status and responses list
        currentTasks[taskId]['status'] = 'Rejected';
        currentTasks[taskId]['responses'] = responses;

        // Update the user's tasks in the Firestore document
        await userDoc.update({
          'tasks': currentTasks,
          'updatedAt': serverTimestamp,
        });
      } else {
        throw Exception('Task ID $taskId not found for this member.');
      }
    } else {
      throw Exception('Member with ID $memberId not found.');
    }
  }

  // Stream<Map<String, dynamic>> getTasksStreamForMember(String memberId) {
  //   final userTasksStream = _firestore
  //       .collection(_userCollectionName)
  //       .doc(memberId)
  //       .snapshots()
  //       .map((userDoc) {
  //     if (!userDoc.exists) {
  //       throw Exception('User with ID $memberId not found.');
  //     }
  //
  //     final userData = userDoc.data();
  //     if (userData == null) {
  //       throw Exception('User data is empty.');
  //     }
  //
  //     // Extract tasks
  //     final tasks = userData['tasks'] as Map<String, dynamic>? ?? {};
  //     return tasks;
  //   });
  //   // Create a stream for task details
  //   Stream<Map<String, Task>> taskDetailsStream(List<String> taskIds) {
  //     if (taskIds.isEmpty) {
  //       return Stream.value({});
  //     }
  //
  //     return _firestore
  //         .collection(_taskCollectionName)
  //         .where(FieldPath.documentId, whereIn: taskIds)
  //         .snapshots()
  //         .map((snapshot) {
  //       return Map.fromEntries(snapshot.docs.map((doc) {
  //         final task = Task.fromMap(doc.data(), doc.id);
  //         return MapEntry(doc.id, task);
  //       }));
  //     });
  //   }
  //
  //   return userTasksStream.switchMap((tasks) {
  //     final taskIds = tasks.keys.toList();
  //     return taskDetailsStream(taskIds).map((taskDetails) {
  //       final result = <String, dynamic>{};
  //
  //       // Collect tasks with details
  //       final taskList = <MapEntry<String, dynamic>>[];
  //       tasks.forEach((taskId, taskData) {
  //         final task = taskDetails[taskId];
  //         if (task != null) {
  //           taskList.add(MapEntry(taskId, {
  //             'title': task.title,
  //             'description': task.description,
  //             'status': taskData['status'],
  //             'deadline': taskData['deadline'],
  //             'dateAssigned': taskData['dateAssigned'],
  //             'dateCompleted': taskData['dateCompleted'],
  //             'responses': taskData['responses'],
  //           }));
  //         }
  //       });
  //
  //       // Sort tasks by deadline (assuming deadline is a string in 'yyyy-MM-dd' format)
  //       taskList.sort((a, b) {
  //         final deadlineA = a.value['deadline'];
  //         final deadlineB = b.value['deadline'];
  //         return deadlineA.compareTo(deadlineB);
  //       });
  //
  //       // Convert sorted task list back to a map
  //       taskList.forEach((entry) {
  //         result[entry.key] = entry.value;
  //       });
  //
  //       return result;
  //     });
  //   });
  // }

  Stream<Map<String, dynamic>> getTasksStreamForMember(String? userId) {
    if (userId == null) {
      // Fetch tasks for all users
      return _firestore
          .collection(_userCollectionName)
          .snapshots()
          .map((snapshot) {
        final allTasks = <String, dynamic>{};

        for (var userDoc in snapshot.docs) {
          final userData = userDoc.data();
          if (userData != null) {
            final tasks = userData['tasks'] as Map<String, dynamic>? ?? {};
            allTasks.addAll(tasks);
          }
        }

        return allTasks;
      });
    } else {
      // Fetch tasks for a specific user
      final userTasksStream = _firestore
          .collection(_userCollectionName)
          .doc(userId)
          .snapshots()
          .map((userDoc) {
        if (!userDoc.exists) {
          throw Exception('User with ID $userId not found.');
        }

        final userData = userDoc.data();
        if (userData == null) {
          throw Exception('User data is empty.');
        }

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

          final taskList = <MapEntry<String, dynamic>>[];
          tasks.forEach((taskId, taskData) {
            final task = taskDetails[taskId];
            if (task != null) {
              taskList.add(MapEntry(taskId, {
                'title': task.title,
                'description': task.description,
                'status': taskData['status'],
                'deadline': taskData['deadline'],
                'dateAssigned': taskData['dateAssigned'],
                'dateCompleted': taskData['dateCompleted'],
                'responses': taskData['responses'],
              }));
            }
          });

          taskList.sort((a, b) {
            final deadlineA = a.value['deadline'];
            final deadlineB = b.value['deadline'];
            return deadlineA.compareTo(deadlineB);
          });

          taskList.forEach((entry) {
            result[entry.key] = entry.value;
          });

          return result;
        });
      });
    }
  }

  Stream<Map<String, dynamic>> getTaskDetailsStream(
      String? userId, String filter, bool isSearching, String searchQuery) {
    return getTasksStreamForMember(userId).map((tasks) {
      final now = DateTime.now();
      final filteredTasks = <String, dynamic>{};

      for (var entry in tasks.entries) {
        final taskDetails = entry.value;
        final deadline = DateTime.parse(taskDetails['deadline']);
        final status = taskDetails['status'];

        if (isSearching) {
          final searchQueryLower = searchQuery.toLowerCase();
          final title = taskDetails['title'].toString().toLowerCase();
          final description =
              taskDetails['description'].toString().toLowerCase();
          final deadlineString =
              taskDetails['deadline'].toString().toLowerCase();

          if (title.contains(searchQueryLower) ||
              description.contains(searchQueryLower) ||
              deadlineString.contains(searchQueryLower)) {
            filteredTasks[entry.key] = taskDetails;
          }
        } else {
          if (filter == 'Active' &&
              ((deadline.isAfter(now) && status == 'pending') ||
                  status == 'Rejected' ||
                  (deadline.isBefore(now) && status == 'pending'))) {
            filteredTasks[entry.key] = taskDetails;
          } else if (filter == 'Late' &&
              (deadline.isBefore(now) &&
                  (status == 'pending' || status == 'Rejected'))) {
            filteredTasks[entry.key] = taskDetails;
          } else if (filter == 'Under Approval' && status == 'Under Approval') {
            filteredTasks[entry.key] = taskDetails;
          } else if (filter == 'Rejected' && status == 'Rejected') {
            filteredTasks[entry.key] = taskDetails;
          } else if (filter == 'Completed' && status == 'Completed') {
            filteredTasks[entry.key] = taskDetails;
          } else if (filter == 'All') {
            filteredTasks[entry.key] = taskDetails;
          }
        }
      }

      return filteredTasks;
    });
  }

  StreamSubscription<void> updateTaskCounts(
    String? userId,
    Function(TaskCounts) onCountsUpdated,
  ) {
    return getTaskDetailsStream(userId, 'All', false, '').listen((tasks) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      int active = 0;
      int late = 0;
      int underApproval = 0;
      int completed = 0;
      int rejected = 0;

      for (var taskDetails in tasks.values) {
        final deadline = DateTime.parse(taskDetails['deadline']);
        final taskDateOnly =
            DateTime(deadline.year, deadline.month, deadline.day);
        final status = taskDetails['status'];

        if (status == 'Under Approval') {
          underApproval++;
        } else if (status == 'Rejected') {
          rejected++;
          active++; // Include rejected tasks in active count
        } else if (status == 'pending') {
          active++;
        } else if (status == 'Completed') {
          completed++;
        }

        if ((status == 'pending' || status == 'Rejected') &&
            taskDateOnly.isBefore(today)) {
          late++;
        }
      }

      final taskCounts = TaskCounts(
        activeCount: active,
        lateCount: late,
        underApprovalCount: underApproval,
        rejectedCount: rejected,
        completedCount: completed,
      );

      onCountsUpdated(taskCounts);
    });
  }
}

class TaskCounts {
  final int activeCount;
  final int lateCount;
  final int underApprovalCount;
  final int completedCount;
  final int rejectedCount;

  TaskCounts({
    required this.activeCount,
    required this.lateCount,
    required this.underApprovalCount,
    required this.completedCount,
    required this.rejectedCount,
  });
}
