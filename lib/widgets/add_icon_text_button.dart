import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/color_provider.dart';

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
    final appColors = Provider.of<ColorProvider>(context).appColors;
    return Row(
      children: [
        TextButton.icon(
          onPressed: onPressed ??
              () {
                notImplementedAlert(context);
              },
          style: const ButtonStyle(alignment: Alignment.centerLeft),
          icon: Icon(iconData,
              color: appColors.borderColor.withOpacity(0.8), size: 25),
          label: Text(label,
              style: TextStyle(
                  color: appColors.borderColor.withOpacity(0.8), fontSize: 14)),
        ),
        const Spacer(),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}
