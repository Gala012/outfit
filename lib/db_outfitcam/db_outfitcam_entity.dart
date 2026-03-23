class HistoryRecord {
  final int? id;
  final String imagePath;
  final String featureType;
  final String createdAt;
  const HistoryRecord({
    this.id,
    required this.imagePath,
    required this.featureType,
    required this.createdAt,
  });
  factory HistoryRecord.fromMap(Map<String, dynamic> map) {
    return HistoryRecord(
      id: map['id'] as int?,
      imagePath: map['image_path'] as String,
      featureType: map['feature_type'] as String,
      createdAt: map['created_at'] as String,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'image_path': imagePath,
      'feature_type': featureType,
      'created_at': createdAt,
    };
  }
}
