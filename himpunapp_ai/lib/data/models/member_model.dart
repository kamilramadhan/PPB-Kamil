class MemberModel {
  final String? id;
  final String name;
  final String nrp;
  final String division;
  final String position;
  final String? photoUrl;
  final DateTime createdAt;

  MemberModel({
    this.id,
    required this.name,
    required this.nrp,
    required this.division,
    required this.position,
    this.photoUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nrp': nrp,
      'division': division,
      'position': position,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return MemberModel(
      id: id ?? map['id'],
      name: map['name'] ?? '',
      nrp: map['nrp'] ?? '',
      division: map['division'] ?? '',
      position: map['position'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  MemberModel copyWith({
    String? id,
    String? name,
    String? nrp,
    String? division,
    String? position,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nrp: nrp ?? this.nrp,
      division: division ?? this.division,
      position: position ?? this.position,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
