import 'package:flutter/material.dart';

import 'movable_list_item.dart';

class MovableList extends StatefulWidget {
  final List<Widget> children;

  const MovableList({super.key, required this.children});

  @override
  State<MovableList> createState() => _MovableListState();
}

class _MovableListState extends State<MovableList> {
  int numOfSelected = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: widget.children
          .map((child) => MovableListItem(
                selectMode: numOfSelected != 0,
                onSelect: (selected) {
                  setState(() {
                    numOfSelected += selected ? 1 : -1;
                  });
                },
                child: child,
              ))
          .toList(),
    );
  }
}
