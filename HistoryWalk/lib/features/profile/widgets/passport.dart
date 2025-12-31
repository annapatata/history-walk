import 'dart:io';
import 'package:flutter/material.dart';
import 'package:historywalk/utils/theme/extensions/passport_theme.dart';

class PassportCard extends StatelessWidget {
  const PassportCard({
    super.key,
    required this.name,
    required this.nationality,
    required this.joinedDate,
    required this.level,
    required this.avatarPath,
    required this.onAvatarTap,
  });

  final String name;
  final String nationality;
  final String joinedDate;
  final String level;
  final String avatarPath;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final passTheme = theme.extension<PassportTheme>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: passTheme.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TopSection(
            name: name,
            nationality: nationality,
            joinedDate: joinedDate,
            level: level,
            avatarPath: avatarPath,
            onAvatarTap: onAvatarTap,
          ),
          const SizedBox(height: 16),
          const _BadgesSection(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TopSection extends StatelessWidget {
  const _TopSection({
    required this.name,
    required this.nationality,
    required this.joinedDate,
    required this.level,
    required this.avatarPath,
    required this.onAvatarTap,
  });

  final String name;
  final String nationality;
  final String joinedDate;
  final String level;
  final String avatarPath;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final passTheme = theme.extension<PassportTheme>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 90,
            height: 110,
            decoration: BoxDecoration(
              color: passTheme.iconColor,
              borderRadius: BorderRadius.circular(12),
              image: avatarPath.isNotEmpty
                  ? DecorationImage(
                      image: FileImage(File(avatarPath)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: avatarPath.isEmpty
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoLine(label: 'Name', value: name),
                  _InfoLine(label: 'Nationality', value: nationality),
                  _InfoLine(label: 'Joined', value: joinedDate),
                  _InfoLine(label: 'Level', value: level),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: passTheme.iconColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label\n',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgesSection extends StatelessWidget {
  const _BadgesSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final passTheme = theme.extension<PassportTheme>()!;

    return Container(
      height: 36,
      width: double.infinity,
      decoration: BoxDecoration(
        color: passTheme.iconColor,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Text(
        'BADGES',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
