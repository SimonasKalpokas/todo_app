class Category {
  final String id;
  final int colorValue;
  String name;

  Category(this.id, this.colorValue, this.name);

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
