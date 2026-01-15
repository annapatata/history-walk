import 'package:flutter/material.dart';

class ProfileProgressBar extends StatelessWidget {
  final double progress; // 0 - 100
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final bool showLabel;
  final String label;
  final Widget? icon;

  const ProfileProgressBar({
    super.key,
    required this.progress,
    this.height = 12, // Reduced height to match the thin bar in the image
    this.color,
    this.backgroundColor,
    this.showLabel = true,
    this.label = "",
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final double clampedProgress = progress.clamp(0, 100);
    // Note: Replaced passTheme for standalone compatibility; 
    // keep your passTheme logic if using the extension.
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 240, 207, 146), // Light cream from image
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            SizedBox(width: 40, height: 40, child: icon!),
            const SizedBox(width: 12),
          ],
          // Wrap the Column in Expanded so it fills the remaining Row width
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLabel)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      label.isNotEmpty
                          ? "$label : ${clampedProgress.toInt()}/100 XP"
                          : "${clampedProgress.toInt()}/100 XP",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13, // To match the pixelated/mono look
                      ),
                    ),
                  ),
                // The Bar Container
                Stack(
                  children: [
                    Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: backgroundColor ?? const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(height),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: clampedProgress / 100,
                      child: Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: color ?? const Color(0xFFE5B132), // Gold color
                          borderRadius: BorderRadius.circular(height),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
