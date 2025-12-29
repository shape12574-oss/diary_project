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
      title: json['title'],
      content: json['content'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      activity: json['activity'],
      photoPath: json['photoPath'],
      aiTags: (json['aiTags'] as String).split(','),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'activity': activity,
      'photoPath': photoPath,
      'aiTags': aiTags.join(','),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'DiaryEntry(id: $id, title: $title, location: $address)';
  }
}