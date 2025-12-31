class UserProfile {
  final String name;
  final String nationality;
  final String avatarPath;
  final DateTime firstLoginDate;
  final int level;
  final int progress;

  UserProfile({
    required this.name,
    required this.nationality,
    required this.avatarPath,
    required this.firstLoginDate,
    required this.level,
    required this.progress,
  });

  UserProfile copyWith({
    String? name,
    String? nationality,
    String? avatarPath,
    int? level,
    int? progress,
  }) {
    return UserProfile(
      name: name ?? this.name,
      nationality: nationality ?? this.nationality,
      avatarPath: avatarPath ?? this.avatarPath,
      firstLoginDate: firstLoginDate,
      level: level ?? this.level,
      progress: progress ?? this.progress,
    );
  }
}
