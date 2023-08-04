import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/base_task.dart';
import '../../providers/selection_provider.dart';

class MovableListItem<T> extends StatefulWidget {
  final Widget child;
  final SelectionItem<T> selectionItem;
  final SelectionProvider<T> selectionProvider;
  const MovableListItem(
      {super.key,
      required this.selectionItem,
      required this.selectionProvider,
      required this.child});

  @override
  State<MovableListItem> createState() => _MovableListItemState();
}

class _MovableListItemState extends State<MovableListItem> {
  bool selected = false;

  void _onSelect() {
    if (selected) {
      widget.selectionProvider.deselect(widget.selectionItem);
    } else {
      widget.selectionProvider.select(widget.selectionItem);
    }
    setState(() {
      selected = !selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: widget.selectionProvider.state != SelectionState.moving
          ? _onSelect
          : null,
      onTap: widget.selectionProvider.isSelecting ? _onSelect : null,
      child: !widget.selectionProvider.isSelecting
          ? widget.child
          : SizedBox(
              child: Row(
                children: [
                  Checkbox(
                    value: selected,
                    onChanged: (value) => _onSelect(),
                  ),
                  Expanded(child: IgnorePointer(child: widget.child)),
                ],
              ),
            ),
    );
  }
}
