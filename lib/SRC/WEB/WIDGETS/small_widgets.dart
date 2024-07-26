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


class LoadingPlaceholder extends StatelessWidget {
  final double height;
  final Color color;

  const LoadingPlaceholder({
    Key? key,
    this.height = 300,
    this.color = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height, // Adjustable height
      child: Center(
        child: CircularProgressIndicator(
          color: color,
        ),
      ),
    );
  }
}
