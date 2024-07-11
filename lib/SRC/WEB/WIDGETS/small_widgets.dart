import 'package:flutter/material.dart';

class divider extends StatelessWidget {
  const divider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 30),
        Divider(
          height: 1,
          color: Color(0xBB949494),
        ),
        SizedBox(height: 30),
      ],
    );
  }
}