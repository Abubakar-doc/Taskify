import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskify/SRC/WEB/MODEL/department.dart';

class DepartmentService {
  final CollectionReference _departmentsCollection = FirebaseFirestore.instance.collection('Department');

  Future<void> createDepartment(Department department) async {
    if (await _departmentExists(department.name)) {
      throw Exception('Department with this name already exists.');
    }
    await _departmentsCollection.add(department.toMap());
  }

  Future<void> updateDepartment(Department department) async {
    await _departmentsCollection.doc(department.id).update(department.toMap());
  }

  Future<void> deleteDepartment(String id) async {
    await _departmentsCollection.doc(id).delete();
  }

  Stream<List<Department>> getDepartmentsForViewDepartmentTable() {
    return _departmentsCollection
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Department.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    }).asBroadcastStream();
  }

  Stream<List<Department>> getDepartmentsForDropDown() {
    return _departmentsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Department.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    }).asBroadcastStream();
  }

  Stream<List<Department>> getDepartmentsForViewDepartmentAndMemberTable() {
    return _departmentsCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Department.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    }).asBroadcastStream();
  }

  Future<bool> _departmentExists(String name) async {
    final querySnapshot = await _departmentsCollection.where('name', isEqualTo: name).get();
    return querySnapshot.docs.isNotEmpty;
  }
}
