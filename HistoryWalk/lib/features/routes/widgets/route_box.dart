import 'package:flutter/material.dart';
import '../../../utils/formatters/years.dart';
import 'package:historywalk/utils/theme/extensions/route_box_theme.dart';
import '../models/route_model.dart';

class RouteBox extends StatelessWidget {
  final RouteModel route;
  final VoidCallback? onTap;
  const RouteBox({super.key, required this.route, this.onTap});

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final boxTheme = theme.extension<RouteBoxTheme>()!;

    // Inside your RouteBox build method
final stopText = route.mapstops.isNotEmpty 
    ? route.mapstops.map((stop) => stop.name).join(", ") 
    : "Loading stops..."; // Fallback if data hasn't arrived yet

    // Dynamic sizes based on screen width
    final imageWidth = screenWidth < 350 ? 80.0 : 100.0;
    final imageHeight = screenWidth < 350 ? 80.0 : 100.0;
    final iconSize = screenWidth < 350 ? 14.0 : 16.0; // adapt icons for tiny screens
    final titleFontSize = screenWidth < 350 ? 14.0 : 16.0;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
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
                route.routepic,
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.cover,
                alignment: Alignment.center,
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
                      route.name,
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
                        Builder(builder: (_) {
                          final stars = route.rating.clamp(0, 5).round();
                          final reviewCount = route.reviewCount;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
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
                          );
                        }),
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
                              route.timePeriods.isNotEmpty
                                  ? route.timePeriods.map((tp)=>tp.displayName).join(",")
                                  : 'General History',
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
                              "${route.duration.inMinutes} min",
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
                              route.difficulty,
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
    ),
    );
  }
}
