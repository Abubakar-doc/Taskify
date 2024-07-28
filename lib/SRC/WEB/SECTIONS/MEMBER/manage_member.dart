import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/SECTIONS/MEMBER/WIDGETS/1_approve_new_member_registration_widget.dart';
import 'package:taskify/SRC/WEB/SECTIONS/MEMBER/WIDGETS/2_active_member_widget.dart';
import 'package:taskify/SRC/WEB/SECTIONS/MEMBER/WIDGETS/3_rejected_member_widget.dart';
import 'package:taskify/SRC/WEB/WIDGETS/small_widgets.dart';

class ManageMember extends StatelessWidget {
  final GlobalKey approveNewUserRegistrationKey;
  final GlobalKey activeMemberKey;
  final GlobalKey rejectedMemberKey;

  const ManageMember({
    super.key,
    required this.approveNewUserRegistrationKey,
    required this.activeMemberKey,
    required this.rejectedMemberKey,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ApproveNewMemberRegistrationWidget(key: approveNewUserRegistrationKey),
          const divider(),
          ActiveMemberWidget(key: activeMemberKey),
          const divider(),
          RejectedMemberWidget(key: rejectedMemberKey),
        ],
      ),
    );
  }
}
