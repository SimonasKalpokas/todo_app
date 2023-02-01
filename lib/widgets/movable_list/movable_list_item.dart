import 'package:flutter/material.dart';

class MovableListItem extends StatefulWidget {
  final Widget child;
  final bool selectMode;
  final void Function(bool) onSelect;
  const MovableListItem(
      {super.key,
      required this.child,
      this.selectMode = false,
      required this.onSelect});

  @override
  State<MovableListItem> createState() => _MovableListItemState();
}

class _MovableListItemState extends State<MovableListItem> {
  bool selected = false;

  void _onSelect() {
    widget.onSelect(!selected);
    setState(() {
      selected = !selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _onSelect,
      child: !widget.selectMode
          ? widget.child
          : SizedBox(
              child: Row(
                children: [
                  Checkbox(
                    value: selected,
                    onChanged: (value) => _onSelect(),
                  ),
                  Expanded(child: widget.child),
                ],
              ),
            ),
    );
  }
}
