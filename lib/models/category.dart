import 'package:todo_app/models/entity.dart';

class Category extends Entity {
  final int colorValue;
  String name;

  Category(this.colorValue, this.name) : super.create();

  Category.fromMap(super.map)
      : colorValue = map['colorValue'],
        name = map['name'],
        super.fromMap();

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map.addAll({
      'colorValue': colorValue,
      'name': name,
    });
    return map;
  }
}
