class WearLog {
  final int? id;
  final String date; // YYYY-MM-DD
  final int outfitId;

  WearLog({
    this.id,
    required this.date,
    required this.outfitId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'outfit_id': outfitId,
    };
  }

  factory WearLog.fromMap(Map<String, dynamic> map) {
    return WearLog(
      id: map['id'] as int?,
      date: map['date'] as String,
      outfitId: map['outfit_id'] as int,
    );
  }
}




