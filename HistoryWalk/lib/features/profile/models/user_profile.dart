class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String nationality;
  final String avatarPath;
  final DateTime firstLoginDate;
  final int level;
  final int progress;
  final List<String> completedRoutes;

  UserProfile({
    required this.name,
    required this.nationality,
    required this.avatarPath,
    required this.firstLoginDate,
    required this.level,
    required this.progress,
    required this.uid,
    required this.email,
    this.completedRoutes = const [],
  });

  // THIS IS THE METHOD THAT IS MISSING
  UserProfile copyWith({
    String? name,
    String? email,
    String? nationality,
    String? avatarPath,
    int? level,
    int? progress,
    List<String>? completedRoutes,
  }) {
    return UserProfile(
      uid: this.uid, // UID should never change
      name: name ?? this.name,
      email: email ?? this.email,
      nationality: nationality ?? this.nationality,
      avatarPath: avatarPath ?? this.avatarPath,
      firstLoginDate: this.firstLoginDate,
      level: level ?? this.level,
      progress: progress ?? this.progress,
      completedRoutes: completedRoutes ?? this.completedRoutes,
    );
  }

  // =========================
  // Local storage helpers
  // =========================

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'nationality': nationality,
      'avatarPath': avatarPath,
      'firstLoginDate': firstLoginDate.toIso8601String(),
      'level': level,
      'progress': progress,
      'completedRoutes': completedRoutes,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      name: json['name'],
      email: json['email'],
      nationality: json['nationality'],
      avatarPath: json['avatarPath'],
      firstLoginDate: DateTime.parse(json['firstLoginDate']),
      level: json['level'],
      progress: json['progress'],
      completedRoutes: List<String>.from(json['completedRoutes'] ?? [])
    );
  }
}
