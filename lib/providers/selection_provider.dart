import 'package:flutter/material.dart';

class SelectionItem<T> {
  final T value;

  const SelectionItem(this.value);

  @override
  bool operator ==(Object other) =>
      other is SelectionItem && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

enum SelectionState {
  inactive,
  selecting,
  moving,
}

class SelectionProvider<T> extends ChangeNotifier {
  final List<SelectionItem<T>> _selectedItems = [];
  SelectionState _state = SelectionState.inactive;

  bool get isSelecting => _state == SelectionState.selecting;
  SelectionState get state => _state;

  List<SelectionItem<T>> get selectedItems => _selectedItems;

  void setStateMoving() {
    _state = SelectionState.moving;
    notifyListeners();
  }

  void select(SelectionItem<T> item) {
    _selectedItems.add(item);
    if (_selectedItems.length == 1) {
      _state = SelectionState.selecting;
    }
    notifyListeners();
  }

  void deselect(SelectionItem<T> item) {
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

  void toggleSelection(SelectionItem<T> item) {
    if (_selectedItems.contains(item)) {
      deselect(item);
    } else {
      select(item);
    }
  }
}
