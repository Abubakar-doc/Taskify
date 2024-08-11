class Department {
  final String id;
  final String name;
  final int createdAt;
  final int updatedAt;

  Department({
    this.id = '',
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // A factory method to create a Department from a map.
  factory Department.fromMap(Map<String, dynamic> map, String documentId) {
    return Department(
      id: documentId,
      name: map['name'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  // Override the toString method
  @override
  String toString() {
    return 'Department(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
