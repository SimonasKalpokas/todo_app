class Category {
  final String id;
  final int colorValue;
  final String name;

  Category(this.id, this.colorValue, this.name);

  @override
  bool operator ==(other) {
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
