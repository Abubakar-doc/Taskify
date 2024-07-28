import 'package:flutter/material.dart';
import 'package:taskify/SRC/COMMON/UTILS/Utils.dart';
import 'package:taskify/SRC/WEB/MODEL/department.dart';
import 'package:taskify/SRC/WEB/SERVICES/department.dart';
import 'package:taskify/SRC/WEB/WIDGETS/small_widgets.dart';
import 'package:taskify/THEME/theme.dart';

class ViewEditSearchDepartmentsWidget extends StatefulWidget {
  ViewEditSearchDepartmentsWidget({super.key});

  GlobalKey get section2Key => _section2Key;
  final GlobalKey _section2Key = GlobalKey();

  @override
  _ViewEditSearchDepartmentsWidgetState createState() =>
      _ViewEditSearchDepartmentsWidgetState();
}

class _ViewEditSearchDepartmentsWidgetState
    extends State<ViewEditSearchDepartmentsWidget>
    with SingleTickerProviderStateMixin {
  final DepartmentService _departmentService = DepartmentService();
  List<Department> departments = [];
  List<Department> filteredDepartments = [];
  bool showAllDepartments = false;
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _loadDepartments() {
    _departmentService.getDepartments().listen((departmentsList) {
      setState(() {
        departments = departmentsList;
        filteredDepartments = List.from(departments);
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget._section2Key,
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
                    controller: searchController,
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
                    filterDepartments(searchController.text);
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
                  _buildTableHeader(),
                  if (isLoading)
                    const LoadingPlaceholder()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: showAllDepartments
                          ? filteredDepartments.length
                          : (filteredDepartments.length > 5
                              ? 5
                              : filteredDepartments.length),
                      itemBuilder: (context, index) {
                        return DepartmentListItem(
                          name: filteredDepartments[index].name,
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
        return department.name.toLowerCase().contains(query);
      }).toList();
      showAllDepartments = false;
    });
  }

  void _editDepartment(Department department) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller =
            TextEditingController(text: department.name);
        bool isLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: const Text('Edit Department'),
              backgroundColor: customLightGrey,
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'New Department Name',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: customAqua),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final updatedName = controller.text.trim();
                          if (updatedName.isNotEmpty) {
                            setState(() {
                              isLoading = true; // Start loading
                            });
                            final updatedDepartment = Department(
                              id: department.id,
                              name: updatedName,
                              createdAt: department.createdAt,
                              updatedAt: DateTime.now().millisecondsSinceEpoch,
                            );
                            await _departmentService
                                .updateDepartment(updatedDepartment);
                            setState(() {
                              isLoading = false; // End loading
                            });
                            Navigator.of(context).pop();
                            Utils().SuccessSnackBar(context,
                                'The department "${department.name}" has been updated to "$updatedName".');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customAqua,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(color: Colors.black),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteDepartment(Department department) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false; // State variable for loading

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: const Text('Delete Department'),
              backgroundColor: customLightGrey,
              content:
                  Text('Are you sure you want to delete ${department.name}?'),
              actions: <Widget>[
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: customAqua),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true; // Start loading
                          });
                          await _departmentService
                              .deleteDepartment(department.id);
                          setState(() {
                            isLoading = false; // End loading
                          });
                          setState(() {
                            departments.removeWhere(
                                (dept) => dept.id == department.id);
                            filteredDepartments.removeWhere(
                                (dept) => dept.id == department.id);
                          });
                          Navigator.of(context).pop();
                          Utils().InfoSnackBar(
                            context,
                            'The department "${department.name}" has been successfully deleted.',
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class DepartmentListItem extends StatelessWidget {
  final String name;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DepartmentListItem(
      {super.key, required this.name, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCell(name),
              _buildActionsCell(),
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