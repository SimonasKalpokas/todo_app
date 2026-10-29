const _minVal = 97; // codeUnit for 'a'
const _maxVal = 123; // codeUnit for 'z' + 1
const _middleVal = (_maxVal + _minVal) ~/ 2;

List<String> nIndexesBetween(int n, String? left, String? right) {
  if (n < 0) throw ArgumentError.value(n, "n", "must not be negative");
  final result = <String>[];
  _fill(result, n, left, right);
  return result;
}

void _fill(List<String> out, int n, String? left, String? right) {
  if (n == 0) return;
  final middle = indexBetween(left, right);

  final leftCount = (n - 1) ~/ 2;
  _fill(out, leftCount, left, middle);

  out.add(middle);

  final rightCount = n - 1 - leftCount;
  _fill(out, rightCount, middle, right);
}

// TODO: add hugRight functionality
// Most of the time new values are inserted on the left
// Add a check to return values closer to right if left == null
String indexBetween(String? left, String? right) {
  if ((left != null &&
          (left.isEmpty || left.codeUnitAt(left.length - 1) == _minVal)) ||
      (right != null &&
          (right.isEmpty || right.codeUnitAt(right.length - 1) == _minVal))) {
    throw ArgumentError(
        "indexes cannot have trailing '${String.fromCharCode(_minVal)}' or be empty");
  }

  if ((left != null && !_isValidIndex(left)) ||
      (right != null && !_isValidIndex(right))) {
    throw ArgumentError(
        "Only characters in range ['${String.fromCharCode(_minVal)}', '${String.fromCharCode(_maxVal - 1)}] are allowed");
  }

  if (left != null && right != null && left.compareTo(right) >= 0) {
    throw ArgumentError("left must be less than right");
  }

  return String.fromCharCodes(
    _indexBetweenHelper(left?.codeUnits, right?.codeUnits),
  );
}

bool _isValidIndex(String index) =>
    index.codeUnits.every((c) => c >= _minVal && c < _maxVal);

List<int> _indexBetweenHelper(List<int>? left, List<int>? right) {
  if ((left == null || left.isEmpty) && (right == null || right.isEmpty)) {
    return [_middleVal];
  }

  if (left == null || left.isEmpty) {
    left = [_minVal];
  }
  if (right == null || right.isEmpty) {
    right = [_maxVal];
  }

  if (left.first == right.first) {
    return [
      left.first,
      ..._indexBetweenHelper(left.sublist(1), right.sublist(1))
    ];
  } else {
    final value = (left.first + right.first) ~/ 2;
    if (value == left.first) {
      return [left.first, ..._indexBetweenHelper(left.sublist(1), null)];
    } else {
      return [value];
    }
  }
}
