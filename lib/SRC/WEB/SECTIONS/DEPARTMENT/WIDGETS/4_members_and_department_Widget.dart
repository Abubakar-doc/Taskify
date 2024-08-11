import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:taskify/SRC/COMMON/MODEL/Member.dart';
import 'package:taskify/SRC/COMMON/UTILS/Utils.dart';
import 'package:taskify/SRC/WEB/MODEL/department.dart';
import 'package:taskify/SRC/WEB/SERVICES/department.dart';
import 'package:taskify/SRC/WEB/SERVICES/member.dart';
import 'package:taskify/SRC/WEB/WIDGETS/multi_select_dropdown_widget.dart';
import 'package:taskify/SRC/WEB/WIDGETS/small_widgets.dart';
import 'package:taskify/THEME/theme.dart';

class MembersAndDepartmentsWidget extends StatefulWidget {
  MembersAndDepartmentsWidget({super.key});

  GlobalKey get section2Key => _section2Key;
  final GlobalKey _section2Key = GlobalKey();

  @override
  _MembersAndDepartmentsWidgetState createState() =>
      _MembersAndDepartmentsWidgetState();
}

class _MembersAndDepartmentsWidgetState
    extends State<MembersAndDepartmentsWidget>
    with SingleTickerProviderStateMixin {
  final DepartmentService _departmentService = DepartmentService();
  List<Department> departments = [];
  List<Department> filteredDepartments = [];
  bool showAllDepartments = false;
  bool isDepartmentsLoading = true;
  bool isMembersLoading = true;
  TextEditingController searchController = TextEditingController();
  final MemberService _memberService = MemberService();
  List<UserModel> memberList = [];
  bool isLoading = true;
  Map<String, List<String>> departmentMembers = {};

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _loadDepartments();
  }

  void _loadMembers() {
    _memberService.getApprovedMembersHavingDepartment().listen((members) {
      setState(() {
        memberList = members;
        isMembersLoading = false;
        _populateDepartmentMembers();
      });
    }).onError((error) {
      print('Error fetching members: $error');
      setState(() {
        isMembersLoading = false;
      });
    });
  }

  void _loadDepartments() {
    _departmentService
        .getDepartmentsForViewDepartmentAndMemberTable()
        .listen((departmentsList) {
      setState(() {
        departments = departmentsList;
        filteredDepartments = List.from(departments);
        isDepartmentsLoading = false;
        _populateDepartmentMembers();
      });
    });
  }

  void _populateDepartmentMembers() {
    if (isDepartmentsLoading || isMembersLoading) return;

    departmentMembers.clear();
    for (var member in memberList) {
      if (!departmentMembers.containsKey(member.departmentId)) {
        departmentMembers[member.departmentId] = [];
      }
      departmentMembers[member.departmentId]!.add(member.name);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
                  'Departments and Members',
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
                      hintText: 'Search departments or members...',
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
                        final department = filteredDepartments[index];
                        final members = departmentMembers[department.id] ??
                            ['No members']; // Get members for the department
                        return DepartmentListItem(
                          departmentName: department.name,
                          memberNames: members, // Pass members
                          onEdit: () {
                            _moveMembers(department, memberList);
                          },
                          onDelete: () {
                            _removeMembers(department, memberList);
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
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Departments',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Members',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Actions on Members',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
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
        return department.name.toLowerCase().contains(query) ||
            (departmentMembers[department.id]
                    ?.any((member) => member.toLowerCase().contains(query)) ??
                false);
      }).toList();
      showAllDepartments = false;
    });
  }

  void _moveMembers(Department department, List<UserModel> allMembers) {
    // Filter members belonging to the current department
    List<UserModel> departmentMembers = allMembers
        .where((member) => member.departmentId == department.id)
        .toList();

    MultiSelectController<String> multiSelectController = MultiSelectController();
    List<ValueItem<String>> options = departmentMembers.map((member) {
      return ValueItem(
        label: member.name,
        value: '${member.name} (${member.email})',
      );
    }).toList();

    // State to hold selected values
    List<String>? selectedValues = [];
    List<String> selectedNames = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController(text: department.name);
        bool isLoading = false;
        final TextEditingController departmentController = TextEditingController();
        Department? selectedDepartment;
        final screenWidth = MediaQuery.of(context).size.width;

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              backgroundColor: customLightGrey,
              title: Text('Move Members from ${department.name} Department to other Departments'),
              content: SizedBox(
                width: screenWidth * 1 / 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Please select the Department and Members.'),
                    ),
                    const SizedBox(height: 16),
                    DropDownSearchFormField(
                      textFieldConfiguration: TextFieldConfiguration(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: customLightGrey,
                          hintText: 'Search Department',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFF938F99),
                              width: 2.0,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                        ),
                        controller: departmentController,
                      ),
                      suggestionsCallback: (pattern) {
                        return getDepartmentSuggestions(pattern, department);
                      },
                      itemBuilder: (context, String suggestion) {
                        return ListTile(
                          title: Text(suggestion),
                        );
                      },
                      itemSeparatorBuilder: (context, index) {
                        return const Divider();
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      onSuggestionSelected: (String suggestion) {
                        if (suggestion != 'Loading...' && suggestion != 'No departments found') {
                          setState(() {
                            selectedDepartment = departments
                                .firstWhere((dept) => dept.name == suggestion);
                            departmentController.text = suggestion;
                          });
                        }
                      },
                      displayAllSuggestionWhenTap: true,
                      validator: (value) {
                        if (value == null || value.isEmpty || value == 'Loading...' || value == 'No departments found') {
                          return 'Please select a department';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    GenericMultiSelectDropdown<String>(
                      controller: multiSelectController,
                      options: options,
                      onOptionSelected: (selectedOptions) {
                        // Update selected values
                        setState(() {
                          selectedValues = selectedOptions
                              .map((item) => item.value)
                              .cast<String>()
                              .toList();
                          selectedNames = selectedOptions
                              .map((item) => item.label)
                              .toList();
                        });
                      },
                      onOptionRemoved: (index, option) {
                        // Handle when options are removed if necessary
                      },
                      hintText: 'Search Members',
                    ),
                  ],
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
                      : selectedDepartment == null || selectedValues!.isEmpty
                      ? null
                      : () async {
                    setState(() {
                      isLoading = true;
                    });

                    // Extract emails from selected values
                    List<String>? emails = selectedValues?.map((value) {
                      // Use regular expression to extract email
                      final RegExp emailRegExp = RegExp(r'\(([^)]+)\)');
                      final match = emailRegExp.firstMatch(value);
                      return match != null ? match.group(1) ?? '' : '';
                    }).toList();

                    // Create an instance of MemberService
                    MemberService memberService = MemberService();

                    try {
                      // Call the method to move members to the selected department
                      await memberService.moveMembersToDepartment(emails!, selectedDepartment!.id);

                      // Show success snackbar with names and emails of moved members
                      Utils().SuccessSnackBar(
                        context,
                        'Successfully moved members: ${selectedNames.join(', ')} to ${selectedDepartment!.name} department',
                      );
                    } catch (e) {
                      Utils().ErrorSnackBar(
                        context,
                        'Error moving members: ${e.toString()}',
                      );
                    }

                    setState(() {
                      isLoading = false;
                    });

                    Navigator.of(context).pop();
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
                    'Move',
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

  void _removeMembers(Department department, List<UserModel> allMembers) {
    // Filter members belonging to the current department
    List<UserModel> departmentMembers = allMembers
        .where((member) => member.departmentId == department.id)
        .toList();

    MultiSelectController<String> multiSelectController = MultiSelectController();
    List<ValueItem<String>> options = departmentMembers.map((member) {
      return ValueItem(
        label: member.name,
        value: '${member.name} (${member.email})',
      );
    }).toList();

    // State to hold selected values
    List<String>? selectedValues = [];
    List<String> selectedNames = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;
        final screenWidth = MediaQuery.of(context).size.width;

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              backgroundColor: customLightGrey,
              title: Text('Remove Members from ${department.name} Department'),
              content: SizedBox(
                width: screenWidth * 1 / 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Please select the Members you want to remove.'),
                    ),
                    const SizedBox(height: 16),
                    GenericMultiSelectDropdown<String>(
                      controller: multiSelectController,
                      options: options,
                      onOptionSelected: (selectedOptions) {
                        // Update selected values
                        setState(() {
                          selectedValues = selectedOptions
                              .map((item) => item.value)
                              .cast<String>()
                              .toList();
                          selectedNames = selectedOptions
                              .map((item) => item.label)
                              .toList();
                        });
                      },
                      onOptionRemoved: (index, option) {
                        // Handle when options are removed if necessary
                      },
                      hintText: 'Search Members',
                    ),
                  ],
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
                      : selectedValues!.isEmpty
                      ? null
                      : () async {
                    setState(() {
                      isLoading = true;
                    });

                    // Extract emails from selected values
                    List<String>? emails = selectedValues?.map((value) {
                      // Use regular expression to extract email
                      final RegExp emailRegExp = RegExp(r'\(([^)]+)\)');
                      final match = emailRegExp.firstMatch(value);
                      return match != null ? match.group(1) ?? '' : '';
                    }).toList();

                    // Create an instance of MemberService
                    MemberService memberService = MemberService();

                    try {
                      // Call the method to update users' department ID to null
                      await memberService.removeMembersFromDepartment(emails!);

                      Utils().SuccessSnackBar(
                        context,
                        'Successfully removed members: ${selectedNames.join(', ')} from ${department.name} department',
                      );
                    } catch (e) {
                      Utils().ErrorSnackBar(
                        context,
                        'Error removing members: ${e.toString()}',
                      );
                    }

                    setState(() {
                      isLoading = false;
                    });

                    Navigator.of(context).pop();
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
                    'Remove',
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


  List<String> getDepartmentSuggestions(
      String query, Department excludeDepartment) {
    if (isLoading) {
      return ['Loading...'];
    } else if (departments.isEmpty) {
      return ['No departments found'];
    }
    return departments
        .where((dept) =>
            dept.name != excludeDepartment.name &&
            dept.name.toLowerCase().contains(query.toLowerCase()))
        .map((dept) => dept.name)
        .toList();
  }
}

class DepartmentListItem extends StatelessWidget {
  final String departmentName;
  final List<String> memberNames;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DepartmentListItem(
      {super.key,
      required this.departmentName,
      required this.memberNames,
      this.onEdit,
      this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCell(departmentName),
              _buildCell(memberNames.join(', ')),
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
                'Move',
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
                'Remove',
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
