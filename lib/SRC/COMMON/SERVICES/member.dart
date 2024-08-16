import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskify/SRC/COMMON/MODEL/Member.dart';

class MemberService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('Users');

  Stream<List<UserModel>> getMembers({String? status}) {
    Query query = _usersCollection;

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<List<UserModel>> getApprovedMembersHavingNoDepartment() {
    return _usersCollection
        .orderBy('updatedAt', descending: false)
        .where('status', isEqualTo: 'Approved')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .where((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        // Check if 'departmentId' is either null or an empty string
        return data != null && (data['departmentId'] == null || data['departmentId'] == '');
      })
          .map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      })
          .toList();
    });
  }

  Stream<List<UserModel>> getApprovedMembersHavingDepartment() {
    return _usersCollection
        .where('status', isEqualTo: 'Approved')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .where((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        // Check if 'departmentId' is neither null nor an empty string
        return data != null && data.containsKey('departmentId') && data['departmentId'] != null && data['departmentId'].toString().isNotEmpty;
      })
          .map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      })
          .toList();
    });
  }

  Stream<List<UserModel>> getApprovedMembersHavingDepartmentForTask() {
    return _usersCollection
        .where('status', isEqualTo: 'Approved')
        .orderBy('updatedAt', descending: false)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .where((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        // Check if 'departmentId' is neither null nor an empty string
        return data != null && data.containsKey('departmentId') && data['departmentId'] != null && data['departmentId'].toString().isNotEmpty;
      })
          .map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      })
          .toList();
    });
  }

  Future<void> updateUserStatus(String uid, String status) async {
    try {
      await _usersCollection.doc(uid).update({'status': status});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserDepartment(String uid, String departmentId) async {
    try {
      await _usersCollection.doc(uid).update({'departmentId': departmentId});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeMembersFromDepartment(List<String> memberEmails) async {
    try {
      // Get the documents for the specified emails
      final QuerySnapshot querySnapshot = await _usersCollection
          .where('email', whereIn: memberEmails)
          .get();

      // Create a batch to perform all updates in one transaction
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        batch.update(doc.reference, {'departmentId': null});
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> moveMembersToDepartment(List<String> memberEmails, String departmentId) async {
    try {
      // Get the documents for the specified emails
      final QuerySnapshot querySnapshot = await _usersCollection
          .where('email', whereIn: memberEmails)
          .get();

      // Create a batch to perform all updates in one transaction
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        batch.update(doc.reference, {'departmentId': departmentId});
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, UserModel>> getMembersByIds(List<String> ids) async {
    try {
      final userMap = <String, UserModel>{};

      // Fetch multiple documents
      final querySnapshot = await _usersCollection.where(FieldPath.documentId, whereIn: ids).get();

      for (var doc in querySnapshot.docs) {
        if (doc.exists) {
          final user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
          userMap[doc.id] = user;
        }
      }

      return userMap;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      // Fetch the document based on the email field
      final querySnapshot = await _usersCollection.where('email', isEqualTo: email).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        if (doc.exists) {
          // Convert the document data to UserModel
          final user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
          return user;
        }
      }
      return null; // Return null if no user is found
    } catch (e) {
      rethrow;
    }
  }




}
