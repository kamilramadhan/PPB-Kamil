class DivisionModel {
  final String? id;
  final String name;
  final String description;
  final String head; // Ketua divisi
  final int memberCount;
  final DateTime createdAt;

  DivisionModel({
    this.id,
    required this.name,
    required this.description,
    required this.head,
    this.memberCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'head': head,
      'memberCount': memberCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DivisionModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return DivisionModel(
      id: id ?? map['id'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      head: map['head'] ?? '',
      memberCount: map['memberCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  DivisionModel copyWith({
    String? id,
    String? name,
    String? description,
    String? head,
    int? memberCount,
    DateTime? createdAt,
  }) {
    return DivisionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      head: head ?? this.head,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
