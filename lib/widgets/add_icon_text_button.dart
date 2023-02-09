import 'package:flutter/material.dart';
import 'package:todo_app/constants.dart';

import 'not_implemented_alert.dart';

class AddIconTextButton extends StatelessWidget {
  final IconData iconData;
  final String label;
  final Widget? trailing;
  final VoidCallback? onPressed;
  const AddIconTextButton(
      {super.key,
      required this.iconData,
      required this.label,
      this.trailing,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: onPressed ??
              () {
                notImplementedAlert(context);
              },
          style: const ButtonStyle(alignment: Alignment.centerLeft),
          icon: Icon(iconData, color: white2.withOpacity(0.8), size: 25),
          label: Text(label,
              style: TextStyle(color: white2.withOpacity(0.8), fontSize: 14)),
        ),
        const Spacer(),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}
