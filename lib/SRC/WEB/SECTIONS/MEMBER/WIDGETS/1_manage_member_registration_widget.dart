import 'package:flutter/material.dart';
import 'package:taskify/SRC/COMMON/MODEL/Member.dart';
import 'package:taskify/SRC/COMMON/UTILS/Utils.dart';
import 'package:taskify/SRC/COMMON/SERVICES/member.dart';
import 'package:taskify/SRC/WEB/WIDGETS/small_widgets.dart';
import 'package:taskify/THEME/theme.dart';

class ManageMemberRegistrationWidget extends StatefulWidget {
  const ManageMemberRegistrationWidget({super.key});

  @override
  _ManageMemberRegistrationWidgetState createState() =>
      _ManageMemberRegistrationWidgetState();
}

class _ManageMemberRegistrationWidgetState
    extends State<ManageMemberRegistrationWidget> {
  final MemberService _userService = MemberService();
  List<UserModel> users = [];
  List<UserModel> filteredUsers = [];
  bool showAllUsers = false;
  bool isLoading = true;
  String filterType = 'All';

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  void _fetchMembers() {
    String? status;

    switch (filterType) {
      case 'Pending':
        status = 'pending';
        break;
      case 'Active':
        status = 'Approved';
        break;
      case 'Rejected':
        status = 'Rejected';
        break;
      default:
        status = null;
    }

    _userService.getMembers(status: status).listen((userList) {
      setState(() {
        users = userList;
        filteredUsers = userList;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Approve New User Registrations',
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
                      hintText: 'Search members...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      filterUsers(value);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    filterUsers(searchController.text);
                  },
                  icon: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter by:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      activeColor: customAqua,
                      value: filterType == 'All',
                      onChanged: (bool? value) {
                        if (value == true) {
                          setState(() {
                            filterType = 'All';
                            _fetchMembers();
                          });
                        }
                      },
                    ),
                    const Text('All', style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 10,),
                    Checkbox(
                      activeColor: customAqua,
                      value: filterType == 'Pending',
                      onChanged: (bool? value) {
                        if (value == true) {
                          setState(() {
                            filterType = 'Pending';
                            _fetchMembers();
                          });
                        }
                      },
                    ),
                    const Text('Pending', style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 10,),
                    Checkbox(
                      activeColor: customAqua,
                      value: filterType == 'Active',
                      onChanged: (bool? value) {
                        if (value == true) {
                          setState(() {
                            filterType = 'Active';
                            _fetchMembers();
                          });
                        }
                      },
                    ),
                    const Text('Active', style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 10,),
                    Checkbox(
                      activeColor: customAqua,
                      value: filterType == 'Rejected',
                      onChanged: (bool? value) {
                        if (value == true) {
                          setState(() {
                            filterType = 'Rejected';
                            _fetchMembers();
                          });
                        }
                      },
                    ),
                    const Text('Rejected', style: TextStyle(color: Colors.white)),
                  ],
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
                      itemCount: showAllUsers
                          ? filteredUsers.length
                          : (filteredUsers.length > 5
                          ? 5
                          : filteredUsers.length),
                      itemBuilder: (context, index) {
                        return UserTableListItem(
                          userEmail: filteredUsers[index].email,
                          userName: filteredUsers[index].name,
                          status: filteredUsers[index].status,
                          onReject: () {
                            _confirmRejectAction(index);
                          },
                          onApprove: () {
                            _confirmApproveAction(index);
                          },
                          disableApprove:
                          filteredUsers[index].status == 'Approved',
                          disableReject:
                          filteredUsers[index].status == 'Rejected',
                        );
                      },
                    ),
                  if (!isLoading && filteredUsers.length > 5 && !showAllUsers)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showAllUsers = true;
                        });
                      },
                      child: Text(
                        'Show More (${filteredUsers.length - 5} more)',
                        style: const TextStyle(
                          color: customAqua,
                        ),
                      ),
                    ),
                  if (!isLoading && showAllUsers && filteredUsers.length > 5)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showAllUsers = false;
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          _buildHeaderCell('User Name', flex: 4),
          _buildHeaderCell('User Email', flex: 4),
          _buildHeaderCell('Registration Status', flex: 3),
          _buildHeaderCell('Actions', flex: 3, textAlign: TextAlign.right),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text,
      {int flex = 1, TextAlign textAlign = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          textAlign: textAlign,
        ),
      ),
    );
  }

  void filterUsers(String query) {
    query = query.toLowerCase();
    setState(() {
      filteredUsers = users.where((user) {
        return user.email.toLowerCase().contains(query) ||
            user.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _confirmApproveAction(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Approve Registration'),
              backgroundColor: Colors.grey[800],
              content: const Text(
                  'Are you sure you want to approve this registration?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
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
                      const status = 'Approved';
                      await _userService.updateUserStatus(
                          filteredUsers[index].uid, status);

                      setState(() {
                        filteredUsers[index].status = status;
                        users[users.indexWhere((user) =>
                        user.uid == filteredUsers[index].uid)]
                            .status = status;
                        isLoading = false;
                      });

                      Navigator.of(context).pop();

                      Utils().SuccessSnackBar(
                          context, 'User registration approved successfully.');
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });

                      Navigator.of(context).pop();

                      Utils().ErrorSnackBar(
                          context, 'Error approving user registration: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customAqua,
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Approve',
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

  void _confirmRejectAction(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Reject Registration'),
              backgroundColor: Colors.grey[800],
              content: const Text(
                  'Are you sure you want to reject this registration?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
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
                      const status = 'Rejected';
                      await _userService.updateUserStatus(
                          filteredUsers[index].uid, status);

                      setState(() {
                        filteredUsers[index].status = status;
                        users[users.indexWhere((user) =>
                        user.uid == filteredUsers[index].uid)]
                            .status = status;
                        isLoading = false;
                      });

                      Navigator.of(context).pop();

                      Utils().SuccessSnackBar(
                          context, 'User registration rejected successfully.');
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });

                      Navigator.of(context).pop();

                      Utils().ErrorSnackBar(
                          context, 'Error rejecting user registration: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Reject',
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

class UserTableListItem extends StatelessWidget {
  final String userEmail;
  final String userName;
  final String status;
  final VoidCallback onReject;
  final VoidCallback onApprove;
  final bool disableApprove;
  final bool disableReject;

  const UserTableListItem({
    super.key,
    required this.userEmail,
    required this.userName,
    required this.status,
    required this.onReject,
    required this.onApprove,
    this.disableApprove = false,
    this.disableReject = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              _buildCell(userName, flex: 4),
              _buildCell(userEmail, flex: 4),
              _buildCell(status, flex: 3),
              _buildActionsCell(flex: 3),
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

  Widget _buildCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildActionsCell({int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: disableApprove ? null : onApprove,
              style: ElevatedButton.styleFrom(
                backgroundColor: disableApprove ? Colors.grey : customAqua,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                'Approve',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: disableReject ? null : onReject,
              style: ElevatedButton.styleFrom(
                backgroundColor: disableReject ? Colors.grey : Colors.red.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                'Reject',
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
