import 'package:flutter/material.dart';
import 'package:taskify/SRC/COMMON/UTILS/Utils.dart';
import 'package:taskify/SRC/WEB/SERVICES/department.dart';
import 'package:taskify/SRC/WEB/SERVICES/member.dart';
import 'package:taskify/THEME/theme.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:taskify/SRC/WEB/MODEL/department.dart';
import 'package:taskify/SRC/COMMON/MODEL/Member.dart';

class AddMembersInDepartmentWidget extends StatefulWidget {
  const AddMembersInDepartmentWidget({super.key});

  @override
  _AddMembersInDepartmentWidgetState createState() =>
      _AddMembersInDepartmentWidgetState();
}

class _AddMembersInDepartmentWidgetState
    extends State<AddMembersInDepartmentWidget> {
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _memberController = TextEditingController();
  final TextEditingController _memberEmailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final DepartmentService _departmentService = DepartmentService();
  final MemberService _memberService = MemberService();

  List<Department> departmentList = [];
  List<UserModel> memberList = [];
  Department? selectedDepartment;
  UserModel? selectedMember;
  bool isLoadingDepartments = true;
  bool isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    _departmentService.getDepartmentsForDropDown().listen((departments) {
      setState(() {
        departmentList = departments;
        isLoadingDepartments = false;
      });
    });

    _memberService.getApprovedMembersHavingNoDepartment().listen((members) {
      setState(() {
        memberList = members;
        isLoadingMembers = false;
      });
    });
  }

  @override
  void dispose() {
    _departmentController.dispose();
    _memberController.dispose();
    _memberEmailController.dispose();
    super.dispose();
  }

  void handleCancel() {
    setState(() {
      _departmentController.clear();
      _memberController.clear();
      _memberEmailController.clear();
      selectedDepartment = null;
      selectedMember = null;
    });
  }

  List<String> getDepartmentSuggestions(String query) {
    if (isLoadingDepartments) {
      return ['Loading...'];
    } else if (departmentList.isEmpty) {
      return ['No departments found'];
    }
    return departmentList
        .where((dept) => dept.name.toLowerCase().contains(query.toLowerCase()))
        .map((dept) => dept.name)
        .toList();
  }

  List<UserModel> getMemberSuggestions(String query) {
    if (isLoadingMembers) {
      return [];
    } else if (memberList.isEmpty) {
      return [];
    }
    return memberList
        .where(
            (member) => member.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Members in Departments',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Department',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
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
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                ),
                controller: _departmentController,
              ),
              suggestionsCallback: (pattern) {
                return getDepartmentSuggestions(pattern);
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
                if (suggestion != 'Loading...' &&
                    suggestion != 'No departments found') {
                  setState(() {
                    selectedDepartment = departmentList
                        .firstWhere((dept) => dept.name == suggestion);
                    _departmentController.text = suggestion;
                  });
                }
              },
              displayAllSuggestionWhenTap: true,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    value == 'Loading...' ||
                    value == 'No departments found') {
                  return 'Please select a department';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Member',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            DropDownSearchFormField(
              textFieldConfiguration: TextFieldConfiguration(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: customLightGrey,
                  hintText: 'Search Member',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                ),
                controller: _memberController,
              ),
              suggestionsCallback: (pattern) {
                if (isLoadingMembers) {
                  return ['Loading...'];
                } else if (memberList.isEmpty) {
                  return ['No members found'];
                }
                return getMemberSuggestions(pattern)
                    .map((member) => member.name)
                    .toList();
              },
              itemBuilder: (context, String suggestion) {
                if (suggestion == 'Loading...') {
                  return const ListTile(
                    title: Text('Loading...'),
                  );
                } else if (suggestion == 'No members found') {
                  return const ListTile(
                    title: Text('No members found'),
                  );
                } else {
                  final member = memberList
                      .firstWhere((member) => member.name == suggestion);
                  return ListTile(
                    title: Text(suggestion),
                    subtitle: Text(member.email),
                  );
                }
              },
              itemSeparatorBuilder: (context, index) {
                return const Divider();
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (String suggestion) {
                if (suggestion != 'Loading...' &&
                    suggestion != 'No members found') {
                  final member = memberList
                      .firstWhere((member) => member.name == suggestion);
                  setState(() {
                    selectedMember = member;
                    _memberController.text = member.name;
                    _memberEmailController.text = member.email;
                  });
                }
              },
              displayAllSuggestionWhenTap: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a member';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _memberEmailController,
              enabled: false, // Disable typing
              decoration: InputDecoration(
                filled: true,
                fillColor: customLightGrey,
                hintText: 'Member Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final department = _departmentController.text;
                              final member = _memberController.text;
                              final memberEmail = _memberEmailController.text;

                              // Get the department ID from the selectedDepartment object
                              final departmentId = selectedDepartment?.id;
                              if (selectedMember != null &&
                                  departmentId != null) {
                                // Show confirmation dialog before adding the member
                                _showAddMemberConfirmationDialog(context,
                                    selectedMember!, selectedDepartment!);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: customAqua,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Add Member',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            handleCancel();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: customAqua,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberConfirmationDialog(
      BuildContext context, UserModel member, Department department) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: const Text('Add Member to Department'),
              backgroundColor: customLightGrey,
              content: Text(
                'Are you sure you want to add ${member.name} to the department ${department.name}?',
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
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      await _memberService.updateUserDepartment(
                          member.uid, department.id);
                      Navigator.of(context).pop();
                      Utils().SuccessSnackBar(
                        context,
                        'The member "${member.name}" has been successfully added to the department "${department.name}".',
                      );
                      // Clear the form after successful addition
                      handleCancel();
                    } catch (error) {
                      Utils().ErrorSnackBar(
                        context,
                        'Failed to add the member "${member.name}" to the department "${department.name}". Please try again.',
                      );
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
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
                    'Add',
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
}
