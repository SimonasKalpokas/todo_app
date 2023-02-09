import 'package:flutter/material.dart';

void notImplementedAlert(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) =>
          const AlertDialog(content: Text("oops not implemented")));
}
