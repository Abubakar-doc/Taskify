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
  final double? height;
  final Color? color;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const LoadingPlaceholder({
    super.key,
    this.height,
    this.color = Colors.grey,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 300, // Default height of 300 if height is null
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: color,
        ),
      ),
    );
  }
}

