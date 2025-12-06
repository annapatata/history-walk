import 'package:flutter/material.dart';
import '../models/time_period.dart';
import '../../../utils/formatters/years.dart';
import 'package:historywalk/utils/theme/extensions/route_box_theme.dart';

class RouteBox extends StatelessWidget {
  const RouteBox({
    required this.title,
    required this.image,
    required this.timePeriod,
    required this.duration,
    required this.difficulty,
    required this.stops,
    required this.stars,
    required this.reviewCount,
    super.key,
  });

  final String title;
  final String image;
  final TimePeriod timePeriod;
  final Duration duration;
  final String difficulty;
  final List<String> stops;
  final int stars;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final boxTheme = theme.extension<RouteBoxTheme>()!;

    final stopText = stops.join(", ");

    // Dynamic sizes based on screen width
    final imageWidth = screenWidth * 0.25; // wider on small screens
    final iconSize = screenWidth < 350 ? 14.0 : 16.0; // adapt icons for tiny screens
    final titleFontSize = screenWidth < 350 ? 14.0 : 16.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        constraints: const BoxConstraints(minHeight: 130),
        decoration: BoxDecoration(
          color: boxTheme.backgroundColor,
          borderRadius: BorderRadius.circular(boxTheme.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: boxTheme.elevation,
              offset: Offset(0, boxTheme.elevation / 2),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT IMAGE
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(boxTheme.borderRadius),
                bottomLeft: Radius.circular(boxTheme.borderRadius),
              ),
              child: Image.asset(
                image,
                width: imageWidth,
                height: 130,
                fit: BoxFit.cover,
              ),
            ),

            // RIGHT CONTENT
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    Text(
                      title,
                      style: TextStyle(
                        color: boxTheme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // STARS + REVIEW COUNT
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ...List.generate(
                          stars,
                          (i) => Icon(Icons.star,
                              color: boxTheme.starColor, size: iconSize),
                        ),
                        ...List.generate(
                          5 - stars,
                          (i) => Icon(Icons.star_border,
                              color: boxTheme.starColor, size: iconSize),
                        ),
                        Text(
                          "  ($stars/5 · $reviewCount reviews)",
                          style: TextStyle(
                            color: boxTheme.textColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // STOP LIST
                    Text(
                      "Stops: $stopText",
                      style: TextStyle(color: boxTheme.textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // INFO ROW (RESPONSIVE)
                    Wrap(
                      spacing: screenWidth * 0.02,
                      runSpacing: 6,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.place,
                                size: iconSize, color: boxTheme.iconColor),
                            const SizedBox(width: 4),
                            Text(
                              formatPeriod(timePeriod),
                              style: TextStyle(
                                  color: boxTheme.textColor, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time,
                                size: iconSize, color: boxTheme.iconColor),
                            const SizedBox(width: 4),
                            Text(
                              "${duration.inMinutes} min",
                              style: TextStyle(
                                  color: boxTheme.textColor, fontSize: 12),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt,
                                size: iconSize, color: boxTheme.iconColor),
                            const SizedBox(width: 4),
                            Text(
                              difficulty,
                              style: TextStyle(
                                  color: boxTheme.textColor, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
