// Reviews_screen.dart
import 'package:flutter/material.dart';
import '../widgets/route_box.dart';
import '../models/time_period.dart';
import 'package:historywalk/common/widgets/searchbar.dart';

//Screen Class
class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 50, right: 50),
      child: Column(//column for everythin
        children: <Widget>[
          Padding(//screen title
            padding: EdgeInsets.all(8),
            child: Center(child: Text('ROUTES',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontSize: 28,            // bigger
              fontWeight: FontWeight.w800, // extra bold
              ),
             ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: HWSearchBar(),
          ),
          Expanded(//list (needs expanded and shrikwrap = true to scroll apparently)
            child: ListView(
              shrinkWrap: true,
              children: [
                RouteBox( 
                  title: "Echoes of Rome", 
                  image: "icons/image.png", 
                  timePeriod: TimePeriod(startYear: -10, endYear: 130), 
                  duration: Duration(minutes: 45), 
                  difficulty: "Cakewalk", 
                  stops: ["Roman Agora", "Hadrian's Library", "Temple of Zeus"], 
                  stars: 4, 
                  reviewCount: 256,
                ),
                RouteBox( title: "Whispers of the Acropolis",image: "icons/acropolis.png",timePeriod:TimePeriod(startYear: -480, endYear: -404),duration: Duration(minutes: 35),difficulty: "Moderate", stops: ["Parthenon","Erechtheion","Temple of Athena Nike"],stars:4,reviewCount: 400),
                RouteBox( title: "Whispers of the Acropolis",image: "icons/acropolis.png",timePeriod:TimePeriod(startYear: -480, endYear: -404),duration: Duration(minutes: 35),difficulty: "Moderate", stops: ["Parthenon","Erechtheion","Temple of Athena Nike"],stars:4,reviewCount: 400),
                RouteBox( title: "Whispers of the Acropolis",image: "icons/acropolis.png",timePeriod:TimePeriod(startYear: -480, endYear: -404),duration: Duration(minutes: 35),difficulty: "Moderate", stops: ["Parthenon","Erechtheion","Temple of Athena Nike"],stars:4,reviewCount: 400),
                RouteBox( title: "Whispers of the Acropolis",image: "icons/acropolis.png",timePeriod:TimePeriod(startYear: -480, endYear: -404),duration: Duration(minutes: 35),difficulty: "Moderate", stops: ["Parthenon","Erechtheion","Temple of Athena Nike"],stars:4,reviewCount: 400),
                RouteBox( title: "Whispers of the Acropolis",image: "icons/acropolis.png",timePeriod:TimePeriod(startYear: -480, endYear: -404),duration: Duration(minutes: 35),difficulty: "Moderate", stops: ["Parthenon","Erechtheion","Temple of Athena Nike"],stars:4,reviewCount: 400),
                RouteBox( title: "Whispers of the Acropolis",image: "icons/acropolis.png",timePeriod:TimePeriod(startYear: -480, endYear: -404),duration: Duration(minutes: 35),difficulty: "Moderate", stops: ["Parthenon","Erechtheion","Temple of Athena Nike"],stars:4,reviewCount: 400),
              ],
            )
          ),
        ],
      )
    );
  }
}
