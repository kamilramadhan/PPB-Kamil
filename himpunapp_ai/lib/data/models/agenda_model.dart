class AgendaModel {
  final String? id;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String time;
  final String status; // 'upcoming', 'ongoing', 'completed'
  final String? photoUrl; // Base64 location proof photo
  final DateTime createdAt;

  AgendaModel({
    this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.time,
    this.status = 'upcoming',
    this.photoUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'date': date.toIso8601String(),
      'time': time,
      'status': status,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AgendaModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return AgendaModel(
      id: id ?? map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      date: map['date'] != null
          ? DateTime.parse(map['date'])
          : DateTime.now(),
      time: map['time'] ?? '',
      status: map['status'] ?? 'upcoming',
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  AgendaModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? date,
    String? time,
    String? status,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return AgendaModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
