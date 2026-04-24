class UserProfile {
  final String id;
  final String name;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      avatarUrl: map['avatarUrl'],
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
