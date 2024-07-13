import 'package:flutter/material.dart';
import 'package:taskify/THEME/theme.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';

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

  // Test data
  List<String> departmentList = ['Dept A', 'Dept B', 'Dept C'];
  List<Map<String, String>> memberList = [
    {'name': 'John Doe', 'email': 'john.doe@example.com'},
    {'name': 'Jane Smith', 'email': 'jane.smith@example.com'},
    {'name': 'ada Johnson', 'email': 'mike.johnson@example.com'},
    {'name': 'bhalu Johnson', 'email': 'mike.johnson@example.com'},
  ];

  String? selectedDepartment;
  Map<String, String> selectedMember = {};

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
      selectedMember = {};
    });
  }

  List<String> getDepartmentSuggestions(String query) {
    return departmentList
        .where((dept) => dept.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<Map<String, String>> getMemberSuggestions(String query) {
    return memberList
        .where((member) =>
        member['name']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(16.0),
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
                setState(() {
                  selectedDepartment = suggestion;
                  _departmentController.text = suggestion;
                });
              },
              displayAllSuggestionWhenTap: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
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
                return getMemberSuggestions(pattern)
                    .map((member) => member['name']!)
                    .toList();
              },
              itemBuilder: (context, String suggestion) {
                final member = memberList
                    .firstWhere((member) => member['name'] == suggestion);
                return ListTile(
                  title: Text(suggestion),
                  subtitle: Text(member['email']!),
                );
              },
              itemSeparatorBuilder: (context, index) {
                return const Divider();
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (String suggestion) {
                final member = memberList
                    .firstWhere((member) => member['name'] == suggestion);
                setState(() {
                  selectedMember = member;
                  _memberController.text = member['name']!;
                  _memberEmailController.text = member['email']!;
                });
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
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Implement Add Member logic here
                              final department = _departmentController.text;
                              final member = _memberController.text;
                              final memberEmail = _memberEmailController.text;
                              // Perform the add member logic with department, member, and memberEmail
                              print('Member Added: $member to Department: $department with Email: $memberEmail');
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
                          onPressed: handleCancel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
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
}
