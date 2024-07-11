import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/WIDGETS/hoverable_stretched_aqua_button.dart';
import 'package:taskify/THEME/theme.dart';

class CreateDepartmentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Department',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Department Name',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: customLightGrey,
              hintText: 'Department Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          HoverableElevatedButton(
            text: 'Create Department',
            onPressed: () {
              // Implement Create Department logic here
            },
          ),
        ],
      ),
    );
  }
}
