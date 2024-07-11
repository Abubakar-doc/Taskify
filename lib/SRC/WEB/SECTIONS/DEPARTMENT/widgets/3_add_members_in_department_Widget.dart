import 'package:flutter/material.dart';
import 'package:taskify/THEME/theme.dart';

class AddMembersInDepartmentWidget extends StatefulWidget {
  @override
  _AddMembersInDepartmentWidgetState createState() =>
      _AddMembersInDepartmentWidgetState();
}

class _AddMembersInDepartmentWidgetState
    extends State<AddMembersInDepartmentWidget> {
  TextEditingController _departmentController = TextEditingController();
  TextEditingController _memberController = TextEditingController();
  TextEditingController _memberEmailController = TextEditingController();

  // Test data
  List<String> departmentList = ['Dept A', 'Dept B', 'Dept C'];
  List<Map<String, String>> memberList = [
    {'name': 'John Doe', 'email': 'john.doe@example.com'},
    {'name': 'Jane Smith', 'email': 'jane.smith@example.com'},
    {'name': 'Mike Johnson', 'email': 'mike.johnson@example.com'},
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

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(16.0),
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
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return departmentList.where((dept) =>
                  dept.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (String dept) {
              setState(() {
                selectedDepartment = dept;
              });
            },
            optionsViewBuilder: (BuildContext context,
                AutocompleteOnSelected<String> onSelected,
                Iterable<String> options) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.5, // Adjust width
                color: customLightGrey, // Background color for options
                child: SingleChildScrollView(
                  child: Column(
                    children: options
                        .map((dept) => Column(
                      children: [
                        ListTile(
                          title: Text(dept),
                          onTap: () {
                            onSelected(dept);
                          },
                        ),
                        Divider(height: 0.5, color: Colors.grey), // Divider
                      ],
                    ))
                        .toList(),
                  ),
                ),
              );
            },
            displayStringForOption: (String dept) => dept,
            fieldViewBuilder: (BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
              _departmentController = textEditingController;
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                onChanged: (value) {
                  setState(() {
                    selectedDepartment = null;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: customLightGrey,
                  hintText: 'Search Department',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0),
                ),
                style: const TextStyle(color: Colors.white),
              );
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
          Autocomplete<Map<String, String>>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<Map<String, String>>.empty();
              }
              return memberList.where((member) =>
                  member['name']!
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (Map<String, String> member) {
              setState(() {
                selectedMember = member;
                _memberController.text = member['name']!;
                _memberEmailController.text = member['email']!;
              });
            },
            optionsViewBuilder: (BuildContext context,
                AutocompleteOnSelected<Map<String, String>> onSelected,
                Iterable<Map<String, String>> options) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.5, // Adjust width
                color: customLightGrey, // Background color for options
                child: SingleChildScrollView(
                  child: Column(
                    children: options
                        .map((member) => Column(
                      children: [
                        ListTile(
                          title: Text(member['name']!),
                          subtitle: Text(member['email']!),
                          onTap: () {
                            onSelected(member);
                          },
                        ),
                        Divider(height: 0.5, color: Colors.grey), // Divider
                      ],
                    ))
                        .toList(),
                  ),
                ),
              );
            },
            displayStringForOption: (Map<String, String> member) =>
            member['name']!,
            fieldViewBuilder: (BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
              _memberController = textEditingController;
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                onChanged: (value) {
                  setState(() {
                    selectedMember = {};
                    _memberEmailController.clear();
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: customLightGrey,
                  hintText: 'Search Member',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0),
                ),
                style: const TextStyle(color: Colors.white),
              );
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
                          // Implement Add Member logic here
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
    );
  }
}
