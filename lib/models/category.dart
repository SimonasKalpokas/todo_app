import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final int colorValue;
  String name;

  Category(this.id, this.colorValue, this.name);

  Category.randomId(this.colorValue, this.name) : id = const Uuid().v4();

  @override
  bool operator ==(other) {
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  Category.fromMap(Map<String, dynamic> map)
      : this(map['id'], map['colorValue'], map['name']);

  Map<String, dynamic> toMap() => {
        'id': id,
        'colorValue': colorValue,
        'name': name,
      };
}
