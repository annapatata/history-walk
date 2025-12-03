// Reviews_screen.dart
import 'package:flutter/material.dart';

//probably should put this routebox somewhere else so that the reviews screen can use it too

//Route subwidget 
class RouteBox extends StatelessWidget
{
  //init
  RouteBox({this.title = '', this.image = "icons/image.png", this.time = 'Time Period', this.dur = 'Duration', this.dif = 'Difficulty', this.stops = 'Stop1,Stop2', this.stars = 0, this.rn = 0, super.key});
  String title;
  String image;
  String time;
  String dur;
  String dif;
  String stops;
  int stars;
  int rn;

  @override
  Widget build(BuildContext context)
  {
    List<Widget> starList = [];
    int i = 0;
    
    //add as many full star icons as the stars var and then reach 5 with only outlines
    for(i=0;i<stars;i++)
    {
      starList.add(Icon(Icons.star_rate_rounded, color: Colors.amberAccent));
    }
    for(i;i<5;i++)
    {
      starList.add(Icon(Icons.star_border_rounded, color: Colors.amberAccent));
    }
    starList.add(Text("($stars/5) - $rn reviews", style: TextStyle(color: Color(0xFFFFFFFF))),); 

    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: 20),
      child: Container( //container for the background color
        height: 110,
        color: Color.fromARGB(255, 119, 87, 39),
        child: Row( //row for image section and text section
          children:[
            Image(image: AssetImage(image)),
            Align(//I think this align doesnt do shit but the point was to make the text not stick to the top (replace with padding or smth if not bored)
              alignment: FractionalOffset(0.2, 0.2), 
              child: Column( //column of text section
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Color(0xFFFFFFFF))), //title
                  Row(//stars
                    children: starList, 
                  ),
                  Row(//stop list text
                    children: [
                      Text("Stops: $stops", style: TextStyle(color: Color(0xFFFFFFFF)))
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.place_outlined, color: Colors.white),
                      Text(time, style: TextStyle(color: Color(0xFFFFFFFF))),
                      Padding(padding: EdgeInsetsGeometry.all(5)),
                      Icon(Icons.access_time, color: Colors.white),
                      Text(dur, style: TextStyle(color: Color(0xFFFFFFFF))),
                      Padding(padding: EdgeInsetsGeometry.all(5)),
                      Icon(Icons.bolt, color: Colors.white,),
                      Text(dif, style: TextStyle(color: Color(0xFFFFFFFF)))
                    ],
                  )
                ],
              )
            )
          ]
        )
      )
    );
  }
}


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
            child: const Center(child: Text('ROUTES')),
          ),
          Padding(//search bar
            padding: EdgeInsets.only(top: 10,bottom: 50),
            child: Container(//search bar background box
              height: 30,
              color: const Color.fromARGB(241, 238, 186, 97),
              child: const Align(//align everything left
                alignment: AlignmentGeometry.centerLeft, 
                child: Row(
                  children: [ 
                    Padding(padding: EdgeInsetsGeometry.all(5)), //padding for spacing
                    Icon(Icons.search, color: Colors.brown,),
                    Text('Search for...', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ]
                )
              )
            ),
          ),
          Expanded(//list (needs expanded and shrikwrap = true to scroll apparently)
            child: ListView(
              shrinkWrap: true,
              children: [
                RouteBox( 
                  title: "Echoes of Rome", 
                  image: "icons/image.png", 
                  time: "10 BCE - 130 CE", 
                  dur: "45 min", 
                  dif: "Cakewalk", 
                  stops: "Roman Agora, Hadrian's Library. Temple of Zeus", 
                  stars: 4, 
                  rn: 256,
                ),
                RouteBox( title: "Route 2",),
                RouteBox( title: "Route 3",),
                RouteBox( title: "Route 4",),
                RouteBox( title: "Route 5",),
                RouteBox( title: "Route 6",),
                RouteBox( title: "Route 7",),
                RouteBox( title: "Route 8",),
                RouteBox( title: "Route 9",),
                RouteBox( title: "Route 10",)
              ],
            )
          ),
        ],
      )
    );
  }
}
