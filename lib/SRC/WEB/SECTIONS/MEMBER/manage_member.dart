import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/SECTIONS/MEMBER/WIDGETS/1_manage_member_registration_widget.dart';

class ManageMember extends StatelessWidget {
  final GlobalKey manageUserRegistrations;

  const ManageMember({
    super.key,
    required this.manageUserRegistrations,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: double.infinity,
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ManageMemberRegistrationWidget(key: manageUserRegistrations),
            ],
          ),
        ),
      ),
    );
  }
}