import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/SECTIONS/MEMBER/WIDGETS/1_approve_new_user_registration_widget.dart';

class ManageMember extends StatelessWidget {
  final GlobalKey approveNewUserRegistrationKey;

  const ManageMember({super.key, required this.approveNewUserRegistrationKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ApproveNewUserRegistrationWidget(key: approveNewUserRegistrationKey),
          ],
        ),
      ),
    );
  }
}
