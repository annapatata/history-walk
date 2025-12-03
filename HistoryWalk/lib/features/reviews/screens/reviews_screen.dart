// Reviews_screen.dart
import 'package:flutter/material.dart';
import 'package:historywalk/features/routes/screens/routes_screen.dart';

class Review extends StatelessWidget
{
  //init
  Review({this.image = "icons/no_pfp.png", this.review = 'review text goes here', this.stars = 0, super.key});
  String image;
  String review;
  int stars;

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

    return Container( //container for the background color
      height: 50,
      color: Color.fromARGB(255, 255, 242, 231),
      child: Row( //row for image section and text section
        children:[
          Padding(padding: EdgeInsetsGeometry.all(5), child: Image(image: AssetImage(image))),
          Align(//I think this align doesnt do shit but the point was to make the text not stick to the top (replace with padding or smth if not bored)
            alignment: FractionalOffset(0.2, 0.2), 
            child: Column( //column of text section
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(//stars
                  children: starList, 
                ),
                SizedBox(
                  width: 100,
                  child: Text(review, overflow: TextOverflow.ellipsis) //review text
                )
              ],
            )
          )
        ]
      )
    );
  }
}



class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  static const int reviews = 256;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 50, right: 50),
      child: Column(//column for everything
        children: [
          Padding(//screen title
            padding: EdgeInsets.all(8),
            child: const Center(child: Text('REVIEWS')),
          ),

          Padding(//search bar
            padding: EdgeInsets.only(top: 10,bottom: 50),
            child: Container(//search bar background box
              height: 30,
              color: const Color.fromARGB(241, 238, 186, 97),
              child: const Align(//align everything left
                alignment: AlignmentGeometry.centerLeft, 
                child: Row(//search bar contents
                  children: [ 
                    Padding(padding: EdgeInsetsGeometry.all(5)), //padding for spacing
                    Icon(Icons.search, color: Colors.brown,),
                    Text('Search for...', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ]
                )
              )
            ),
          ),

          RouteBox( 
                  title: "Echoes of Rome", 
                  image: "icons/image.png", 
                  time: "10 BCE - 130 CE", 
                  dur: "45 min", 
                  dif: "Cakewalk", 
                  stops: "Roman Agora, Hadrian's Library. Temple of Zeus", 
                  stars: 4, 
                  rn: reviews,
                ),
                
          Padding(//write a review
            padding: EdgeInsets.only(top: 10,bottom: 50),
            child: Container(//write a review background box
              height: 30,
              color: const Color.fromARGB(240, 238, 166, 41),
              child: const Center(//write a review contents
                child: Text('Write a Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ),
          ),

          Align(//align just for text
            alignment: Alignment.centerLeft,
            child: Text('Photo Gallery (11)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),

          Padding(padding: EdgeInsetsGeometry.all(5)),
          
          //hiorizontal images scroll
          Container(//backround box for that^
            height: 110,
            width: 2000,
            color: Colors.white,
            child: Expanded(
              child: ListView(//horizontal image list (doesnt scroll very well for me so try it out too and lmk what you think)
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  Icon(Icons.image, size: 100,),
                  Icon(Icons.image, size: 100,),
                  Icon(Icons.image, size: 100,),
                  Icon(Icons.image, size: 100,),
                  Icon(Icons.image, size: 100,),
                  Icon(Icons.image, size: 100,),
                  Icon(Icons.image, size: 100,),
                  Icon(Icons.image, size: 100,),
                ],
              )
            ),
          ),
          Padding(padding: EdgeInsetsGeometry.all(10)),

          //reviews header
          Container(//header backrground
                  height: 30,
                  color: const Color.fromARGB(240, 238, 166, 41),
                  child: const Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Padding(
                      padding: EdgeInsetsGeometry.directional(start: 10),
                      child: Text('Reviews ($reviews)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), //header text
                    )
                  )
                ),
          //reviews list
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                Review(stars: 3, review: "what happens when ",),
                Review(),
                Review(),
                Review(),
                Review(),
                Review(),
              ],
            )
          ),
        ],
      )
    );
  }
}
