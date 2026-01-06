class ClothingItem {
  final int? id;
  final String name;
  final String category;
  final String imagePath;
  final String tags; // 存储标签，通常为逗号分隔的字符串
  final int colorValue; // 新增：存储颜色值

  ClothingItem({
    this.id,
    required this.name,
    required this.category,
    required this.imagePath,
    required this.tags,
    this.colorValue = 0xFFFFC0CB, // 默认粉色
  });

  // 将 ClothingItem 转换为 Map，以便存入 sqflite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'image_path': imagePath,
      'tags': tags,
      'color_value': colorValue,
    };
  }

  // 从 Map 转换为 ClothingItem 对象
  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      imagePath: map['image_path'] as String,
      tags: map['tags'] as String,
      colorValue: map['color_value'] as int? ?? 0xFFFFC0CB,
    );
  }
}
