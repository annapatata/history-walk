class Badge {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final bool unlocked;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.unlocked,
  });

  Badge copyWith({bool? unlocked}) {
    return Badge(
      id: id,
      title: title,
      description: description,
      iconPath: iconPath,
      unlocked: unlocked ?? this.unlocked,
    );
  }

  // 🔽 Persistence
  Map<String, dynamic> toJson() => {
        'id': id,
        'unlocked': unlocked,
      };

  static Badge fromJson(
    Map<String, dynamic> json,
    Badge base,
  ) {
    return base.copyWith(
      unlocked: json['unlocked'] ?? false,
    );
  }
}
