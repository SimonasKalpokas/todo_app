import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ListDraggable extends StatelessWidget {
  final List<Widget> children;
  const ListDraggable({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    VerticalDragGestureRecognizer drag = VerticalDragGestureRecognizer();
    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) {
        return Draggable(
          data: index,
          axis: Axis.vertical,
          feedback: SizedBox(
              width: MediaQuery.of(context).size.width,
              child:
                  Material(color: Colors.transparent, child: children[index])),
          childWhenDragging: Container(),
          child: children[index],
        );
      },
    );
  }
}
