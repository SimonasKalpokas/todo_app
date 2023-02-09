import 'package:flutter/material.dart';
import 'package:todo_app/constants.dart';

class FormLabel extends StatelessWidget {
  final String text;
  final double fontSize;
  const FormLabel({super.key, required this.text, this.fontSize = 16.0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Text(
        text,
        style: TextStyle(color: white2, fontSize: fontSize),
      ),
    );
  }
}
