class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.bio,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'created_at': createdAt.toIso8601String(),
    'bio': bio,
    'avatar_url': avatarUrl,
  };

  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final String? bio;
  final String? avatarUrl;
}
