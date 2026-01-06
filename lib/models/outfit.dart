class Outfit {
  final int? id;
  final String name;
  final String category; // e.g., 约会, 上班, 游玩
  final List<int> clothingItemIds; // 存储衣物 ID 的列表
  final DateTime createdDate;

  Outfit({
    this.id,
    required this.name,
    required this.category,
    required this.clothingItemIds,
    required this.createdDate,
  });

  // 将 Outfit 转换为 Map，以便存入 sqflite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'clothing_item_ids': clothingItemIds.join(','), // 存为逗号分隔字符串
      'created_date': createdDate.toIso8601String(),
    };
  }

  // 从 Map 转换为 Outfit 对象
  factory Outfit.fromMap(Map<String, dynamic> map) {
    return Outfit(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      clothingItemIds: (map['clothing_item_ids'] as String)
          .split(',')
          .where((s) => s.isNotEmpty)
          .map(int.parse)
          .toList(),
      createdDate: DateTime.parse(map['created_date'] as String),
    );
  }
}
