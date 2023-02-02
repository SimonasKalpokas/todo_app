import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/selection_provider.dart';

class MovableListItem extends StatefulWidget {
  final Widget child;
  final SelectionItem selectionItem;
  const MovableListItem(
      {super.key, required this.selectionItem, required this.child});

  @override
  State<MovableListItem> createState() => _MovableListItemState();
}

class _MovableListItemState extends State<MovableListItem> {
  bool selected = false;

  void _onSelect() {
    var selectionProvider =
        Provider.of<SelectionProvider>(context, listen: false);
    if (selected) {
      selectionProvider.deselect(widget.selectionItem);
    } else {
      selectionProvider.select(widget.selectionItem);
    }
    setState(() {
      selected = !selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    var selectionProvider =
        Provider.of<SelectionProvider>(context, listen: true);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress:
          selectionProvider.state != SelectionState.moving ? _onSelect : null,
      onTap: selectionProvider.isSelecting ? _onSelect : null,
      child: !selectionProvider.isSelecting
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
