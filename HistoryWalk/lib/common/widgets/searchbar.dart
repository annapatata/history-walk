import 'package:flutter/material.dart';
import 'package:historywalk/utils/theme/extensions/searchbar_theme.dart';

class HWSearchBar extends StatelessWidget {
  final String placeholder;

  const HWSearchBar({this.placeholder = "Search for...", super.key});

  @override
  Widget build(BuildContext context) {

    // use the SearchbarTheme
    final searchbarTheme = Theme.of(context).extension<SearchbarTheme>()!;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: searchbarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: searchbarTheme.elevation,
              offset: Offset(0, searchbarTheme.elevation / 2),
            )
          ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.search, color: searchbarTheme.iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: null,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: searchbarTheme.textColor,
                ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText:placeholder,
                hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: searchbarTheme.textColor.withOpacity(0.6),
                    ),
              )

            ),
          ),
        ],
      ),
    );
  }
}
