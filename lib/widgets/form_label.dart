import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/color_provider.dart';

class FormLabel extends StatelessWidget {
  final String text;
  final double fontSize;
  const FormLabel({super.key, required this.text, this.fontSize = 16.0});

  @override
  Widget build(BuildContext context) {
    final appColors = Provider.of<ColorProvider>(context).appColors;
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Text(
        text,
        style: TextStyle(color: appColors.borderColor, fontSize: fontSize),
      ),
    );
  }
}
