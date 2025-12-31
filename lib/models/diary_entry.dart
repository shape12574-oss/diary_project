class DiaryEntry {
  final int? id;
  final String title;
  final String content;
  final double latitude;
  final double longitude;
  final String address;
  final String activity;
  final String photoPath;
  final List<String> aiTags;
  final DateTime createdAt;

  DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.activity,
    required this.photoPath,
    required this.aiTags,
    required this.createdAt,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      address: json['address'] ?? 'Unknown location',
      activity: json['activity'] ?? 'unknown',
      photoPath: json['photoPath'] ?? '',
      aiTags: _parseAiTags(json['aiTags']),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static List<String> _parseAiTags(dynamic tagsData) {
    if (tagsData == null) return [];
    if (tagsData is String) {
      return tagsData.isEmpty ? [] : tagsData.split(',');
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'content': content,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'activity': activity,
      'photoPath': photoPath ?? '',
      'aiTags': aiTags.join(','),
      'createdAt': createdAt.toIso8601String(),
    };


    if (id != null) {
      map['id'] = id!;
    }

    return map;
  }

  @override
  String toString() {
    return 'DiaryEntry(id: $id, title: $title, location: $address)';
  }
}