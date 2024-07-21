import 'package:flutter/material.dart';
import 'package:taskify/THEME/theme.dart';

class ViewEditSearchDepartmentsWidget extends StatefulWidget {
   ViewEditSearchDepartmentsWidget({super.key});

  // Getter to provide access to section2Key
  GlobalKey get section2Key => _section2Key;
  final GlobalKey _section2Key = GlobalKey();

  @override
  _ViewEditSearchDepartmentsWidgetState createState() => _ViewEditSearchDepartmentsWidgetState();
}

class _ViewEditSearchDepartmentsWidgetState extends State<ViewEditSearchDepartmentsWidget> {
  List<String> departments = [
    'HR',
    'IT',
    'Finance',
    'Marketing',
    'Sales',
    'Operations',
    'Legal',
    'Engineering',
    'Support',
    'Product'
  ];
  List<String> filteredDepartments = [];
  bool showAllDepartments = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredDepartments.addAll(departments);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget._section2Key, // Use widget._section2Key here
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Departments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex: 1,
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: customLightGrey,
                      hintText: 'Search departments...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      filterDepartments(value);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Optional: Implement search logic here
                  },
                  icon: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: customLightGrey,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  _buildTableHeader(), // Table Header with titles
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: showAllDepartments
                        ? filteredDepartments.length
                        : (filteredDepartments.length > 5
                        ? 5
                        : filteredDepartments.length),
                    itemBuilder: (context, index) {
                      return DepartmentListItem(
                        name: filteredDepartments[index],
                        onEdit: () {
                          _editDepartment(filteredDepartments[index]);
                        },
                        onDelete: () {
                          _deleteDepartment(filteredDepartments[index]);
                        },
                      );
                    },
                  ),
                  if (filteredDepartments.length > 5 && !showAllDepartments)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showAllDepartments = true;
                        });
                      },
                      child: Text(
                        'Show More (${filteredDepartments.length - 5} more)',
                        style: const TextStyle(
                          color: customAqua,
                        ),
                      ),
                    ),
                  if (showAllDepartments && filteredDepartments.length > 5)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showAllDepartments = false;
                        });
                      },
                      child: const Text(
                        'Show Less',
                        style: TextStyle(
                          color: customAqua,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Name',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          Text(
            'Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  void filterDepartments(String query) {
    query = query.toLowerCase();
    setState(() {
      filteredDepartments = departments.where((department) {
        return department.toLowerCase().contains(query);
      }).toList();
      // Reset showAllDepartments when filtering
      showAllDepartments = false;
    });
  }

  void _editDepartment(String departmentName) {
    // Placeholder function for editing department
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Department'),
          backgroundColor: customLightGrey,
          content: TextField(
            controller: TextEditingController(text: departmentName),
            onChanged: (value) {
              // Update department name logic here if needed
            },
            decoration: const InputDecoration(
              labelText: 'New Department Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: customAqua), // Match your theme color
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement save logic here
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: customAqua, // Match your theme color
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteDepartment(String departmentName) {
    // Placeholder function for deleting department
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Department'),
          backgroundColor: customLightGrey,
          content: Text('Are you sure you want to delete $departmentName?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: customAqua), // Match your theme color
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement delete logic here
                setState(() {
                  departments.remove(departmentName);
                  filteredDepartments.remove(departmentName);
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400, // Use your delete button color
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DepartmentListItem extends StatelessWidget {
  final String name;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DepartmentListItem({super.key, required this.name, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCell(name), // Department name cell
              _buildActionsCell(), // Actions cell
            ],
          ),
          const Divider(
            height: 1,
            color: Color(0xBB949494),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(String text) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildActionsCell() {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: onEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: customAqua,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                'Edit',
                style: TextStyle(
                  color: customDarkGrey,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}