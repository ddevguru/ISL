class User {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final String? bio;
  final String? phoneNumber;
  final String? country;
  final String languagePreference;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final bool isActive;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
    this.bio,
    this.phoneNumber,
    this.country,
    this.languagePreference = 'en',
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
    this.isActive = true,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    String f = firstName.isNotEmpty ? firstName[0] : '';
    String l = lastName.isNotEmpty ? lastName[0] : '';
    return (f + l).toUpperCase();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profilePicture: json['profile_picture'],
      bio: json['bio'],
      phoneNumber: json['phone_number'],
      country: json['country'],
      languagePreference: json['language_preference'] ?? 'en',
      isOnline: json['is_online'] ?? false,
      lastSeen: json['last_seen'] != null ? DateTime.parse(json['last_seen']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture': profilePicture,
      'bio': bio,
      'phone_number': phoneNumber,
      'country': country,
      'language_preference': languagePreference,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? profilePicture,
    String? bio,
    String? phoneNumber,
    String? country,
    String? languagePreference,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      country: country ?? this.country,
      languagePreference: languagePreference ?? this.languagePreference,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
