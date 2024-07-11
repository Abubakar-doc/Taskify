import 'package:flutter/material.dart';
import 'package:taskify/THEME/theme.dart';

class HoverableElevatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const HoverableElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  _HoverableElevatedButtonState createState() =>
      _HoverableElevatedButtonState();
}

class _HoverableElevatedButtonState extends State<HoverableElevatedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _mouseEnter(true),
      onExit: (_) => _mouseEnter(false),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
          _isHovered ? customAqua.withOpacity(0.8) : customAqua,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: widget.onPressed,
        child: Container(
          width: double.infinity,
          height: 40,
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _mouseEnter(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }
}
