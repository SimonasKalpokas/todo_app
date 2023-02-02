import 'package:flutter/material.dart';

class SelectionItem {
  final String id;
  final String? parentId;

  const SelectionItem(this.id, {this.parentId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectionItem && id == other.id && parentId == other.parentId;

  @override
  int get hashCode => id.hashCode ^ parentId.hashCode;
}

enum SelectionState {
  inactive,
  selecting,
  moving,
}

class SelectionProvider extends ChangeNotifier {
  final List<SelectionItem> _selectedItems = [];
  SelectionState _state = SelectionState.inactive;

  bool get isSelecting => _state == SelectionState.selecting;
  SelectionState get state => _state;

  List<SelectionItem> get selectedItems => _selectedItems;

  void setStateMoving() {
    _state = SelectionState.moving;
    notifyListeners();
  }

  void select(SelectionItem item) {
    _selectedItems.add(item);
    if (_selectedItems.length == 1) {
      _state = SelectionState.selecting;
    }
    notifyListeners();
  }

  void deselect(SelectionItem item) {
    _selectedItems.remove(item);
    if (_selectedItems.isEmpty) {
      _state = SelectionState.inactive;
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedItems.clear();
    _state = SelectionState.inactive;
    notifyListeners();
  }

  void toggleSelection(SelectionItem item) {
    if (_selectedItems.contains(item)) {
      deselect(item);
    } else {
      select(item);
    }
  }
}
